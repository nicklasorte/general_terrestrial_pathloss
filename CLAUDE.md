# general_terrestrial_pathloss

MATLAB toolbox for terrestrial radio propagation path loss calculations across multiple base stations and protection points, supporting parallel multi-server execution.

## Tech Stack

- MATLAB (App Designer, Parallel Computing Toolbox, Statistics and Machine Learning Toolbox)
- Propagation models: TIREM5, ITM (Longley-Rice), P2001, matlab_longley_rice
- Clutter model: P2108 terrestrial clutter loss

## File Naming Convention

Revisions are tracked in filenames — `_revN.m` suffix. **Do not modify an existing revision file; create the next revision number** (e.g., `rev14.m` → `rev15.m`) unless explicitly told to edit in place. The latest revision of a file is always the active one.

## Key Files

| File | Role |
|------|------|
| `part1_calc_pathloss_clutter2108_dist_max64_rev14.m` | Main orchestrator: chunked parallel pathloss calculation with P2108 clutter |
| `parfor_rand_parchunk_PropModel_precheck_order_rev9.m` | parfor worker: precheck + calculate one chunk |
| `propagation_clean_up_server_dyn_chunks_rev4.m` | Post-calculation cleanup of sub-chunk files |
| `agg_check_single_point_rev1.m` | Monte Carlo aggregate interference check for a single point |
| `p2108_terrestrial_clutter_loss_vector.m` | Vectorised P2108 clutter loss (dist_km × reliability) |

## Dynamic Chunks Pattern

IMPORTANT: All files that compute `num_chunks` must use this exact pattern — no hard upper cap:

```matlab
dyn_chunks = ceil(num_bs/1000)
num_chunks = max([24, dyn_chunks])
```

Do not use if/elseif clamping (e.g. capping at 64). This is the agreed standard across `part1_*`, `propagation_clean_up_*`, and the parfor worker.

## Parallel / Multi-Server Architecture

- `parfor` distributes chunks across workers; each worker handles one chunk index
- Sub-chunk files are named `sub_<idx>_<model>_pathloss_<point>_<sim>_<folder>.mat`
- Aggregated files are named `<model>_pathloss_<point>_<sim>_<folder>.mat`
- `persistent_var_exist_with_corruption` is used for all file existence checks — never use `exist()` directly
- `persistent_delete_rev1` is used for all file deletions
- Retry loops (`while retry==1 ... catch ... end`) are required around all file I/O to handle concurrent server access
- Re-check `var_exist` after assembly before saving — another server may have written the file concurrently

## Code Patterns to Follow

**Saving files** — always guard with a var_exist check before saving, and wrap in a retry loop:
```matlab
[var_exist1] = persistent_var_exist_with_corruption(app, file_name);
if var_exist1 == 0
    retry_save = 1;
    while(retry_save == 1)
        try
            save(file_name, 'variable')
            retry_save = 0;
        catch
            retry_save = 1;
            pause(1)
        end
    end
end
```

**Error messages** — always include variable values in the message string, never use bare `horzcat()` or `disp()` for debug output:
```matlab
disp_progress(app, strcat('Error: description: var=', num2str(var), ' point_idx=', num2str(point_idx)))
```

**NaN checks on 2D arrays** — use `any(isnan(array(:)))`, not `any(isnan(array))`:
```matlab
if any(isnan(pathloss(:)))
```

## Git Workflow

- Feature branches must be named `claude/<description>-<sessionId>`
- Push with `git push -u origin <branch-name>`
- Commit messages: imperative mood, describe *why* not just *what*

## Pre-PR Checklist

**YOU MUST run `/simplify` on all changed files before every PR.** Do not push without doing this.

## What Not to Do

- Do not use `exist()` for file checks — use `persistent_var_exist_with_corruption`
- Do not delete files directly — use `persistent_delete_rev1`
- Do not add an upper cap to `num_chunks` (no `elseif dyn_chunks > N`)
- Do not leave `tf_stop_subchunk` or similar interim state flags — use `var_exist` re-checks instead
- Do not leave commented-out old revision calls in active code
- Do not use `size()` to re-query a variable whose size has not changed since it was last queried

function disp_progress(app,label1)

    if isa(app,'double')
        label1
        %pause(0.01)
    else
        app.TextArea.Value={label1};
        pause(0.01)
    end
    
end
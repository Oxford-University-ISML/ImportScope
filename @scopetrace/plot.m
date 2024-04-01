function fig = plot(obj, ax)
    %plot - Produce a quick plot of the raw data, overloads 
    % the plot function for scopetrace classes.
    %
    % INPUT     obj - The object.
    %
    %           ax - (Optional) The handle of a graphics figure.
    %
    % OUTPUT    fig - The handle for the figure that was
    %                 created or plotted into.
    %
    arguments
        obj (1,1) scopetrace
        ax  (1,1) matlab.graphics.axis.Axes = axes()
    end
    
    if obj.valid_import
        plot(ax, obj.time, obj.voltage)
        fig = ax.Parent;
    else
        eid = "scopetrace:invalid_import";
        msg = "Unable to plot an invalid import.";
        throwAsCaller(MException(eid, msg))

    end
end

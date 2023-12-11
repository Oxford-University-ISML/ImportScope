function wfm = waveform_single(obj)
%SingleWaveform - Get the waveform data from the object in single precision.
%
% INPUT     obj - The object.
%
% OUTPUT    SingleWaveform - A struct containing time and
%                            voltage values for the raw data in
%                            single precision. This struct also
%                            included errors for the single
%                            approximation and a quality field
%                            that tries to quantify how well
%                            the single approximation has
%                            worked.
%
% REMARKS 1) The only advantage of this function is a reduction
%            in workspace size, if not using CachedTrace there
%            should never be a need for this
if obj.valid_import
    switch obj.TraceType
        case "LeCroy (.trc)"
            [wfm.time   ,TimeError   ] = obj.GetLeCroyTrcTimeSingle;
            [wfm.voltage,VoltageError] = obj.GetLeCroyTrcVoltageSingle;
            wfm.Quality = 1 - hypot(TimeError,VoltageError);
        case "LeCroy (.dat)"
            [wfm.time   ,TimeError   ] = obj.GetLeCroyDatTimeSingle;
            [wfm.voltage,VoltageError] = obj.GetLeCroyDatVoltageSingle;
            wfm.Quality = 1 - hypot(TimeError,VoltageError);
        case "Tektronix (.wfm)"
            [wfm.time   ,TimeError   ] = obj.GetTektronixWfmTimeSingle;
            [wfm.voltage,VoltageError] = obj.GetTektronixWfmVoltageSingle;
            wfm.Quality = 1 - hypot(TimeError,VoltageError);
        case "Tektronix (.isf)"
            [wfm.time   ,TimeError   ] = obj.GetTektronixIsfTimeSingle;
            [wfm.voltage,VoltageError] = obj.GetTektronixIsfVoltageSingle;
            wfm.Quality = 1 - hypot(TimeError,VoltageError);
        case "Tektronix (.dat)"
            [wfm.time   ,TimeError   ] = obj.GetTektronixDatTimeSingle;
            [wfm.voltage,VoltageError] = obj.GetTektronixDatVoltageSingle;
            wfm.Quality = 1 - hypot(TimeError,VoltageError);
    end
else
    wfm = "Invalid Import";
end
end

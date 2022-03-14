# ScopeTrace
## Summary
An object for importing binary oscilloscope files from either Tektronix or LeCroy oscilloscopes found within the ISML Lab. This object will manage storage, summarising metadata, and accessing of raw data for a variety of filetypes. Where file types are not conducive to quick access (.csv and .dat a couple of examples) the object will create binary files to accompany the raw file, these will allow all future imports to run much quicker.

## Dependencies
None

## Installation
Just download and put it somewhere logical. This package is used by other tools (`PDVTrace`, `PDVAnalysis` & `LightGate`) so you'll want it to have a fairly logical path.

## Constructor Arguments
All given as Name-Value pairs, all optional[^1]

| Name              | DataType      | Default           | Description                                                           |
| -------------     | ------------- | ----------------- | --------------------------------------------------------------------- |
| `"FilePath"`      | string        | N/A               | Path to a scope file, can be relative but absolute is more robust.    |
| `"Echo"`          | logical       | false             | Flag for slightly more verbose mode.                                  |
| `"CachedTrace"`   | logical       | false             | Flag for enforce all data is stored in workspace[^2].

[^1]: If run without arguments ScopeTrace will launch a file selection window for you to pick the scope file.
[^2]: This is instead of data being read in when needed. Access to data should be very quick even without enabling this (sometimes the first read is slow if filetypes are not binary). You should really only use the if you want the fastest possible access to data and loads of free memory.

## Properties

| PropertyName      |  DataType     | Summary                                                                   |
| ----------------- | ------------- | ------------------------------------------------------------------------- |
| FilePath          | string        | The path given to the raw oscilloscope trace                              |
| TraceType         | string        | A string containing a descriptor of the type of scope.                    |
| Info              | struct        | As much metadata about the oscilloscope trace as could be imported.       |
| Time              | numeric array | Column vector containing time values for the oscilloscope trace.          |
| Voltage           | numeric array | Column vector containing voltage values for the oscilloscope trace.       |
| SecondVoltage     | string[^4]    | Column vector containing secondary voltage values if this data exists.    |
| UserText          | string[^4]    | UserText, a field that may be present in some binary oscilloscope files.  |
| TrigtimeArray     | string[^4]    | Tigger Times, this will only be populated in multi-trigger traces.        |
| RisTimeArray      | string[^4]    | Information about Random Interleaved Sampling should it be used.          |

[^4]: The framework associated with populating these properties are not validated as we have never used them! If you try to access these a string will be returned asking you to send me the file so I can actually validate the methods here.

## Methods

| MethodName        | Input                                                     | Output                                                | Description                                                   |
| ----------------- | --------------------------------------------------------- | ----------------------------------------------------- | ------------------------------------------------------------- |
| PlotTrace         | obj - The object. <br /> Ax - A figure handle (Optional). | TracePlot - The figure handle.                        | Produce a quick plot of the raw data.                         |
| Waveform          | obj - The object.                                         | Waveform - A struct containing time & voltage arrays  | Get the waveform data from the object.                        |
| SingleWaveform    | obj - The object.                                         | SingleWaveform - As above but single precision[^5]    | Get the waveform data from the object in single precision.    |
| time              | obj - The object.                                         | Time property                                         | This is purely used for covering potential syntax variation.  |
| voltage           | obj - The object.                                         | Voltage property                                      | This is purely used for covering potential syntax variation.

[^5]: This struct also includes errors for the single approximation and a quality field that tries to quantify how well the single approximation has worked. The only advantage of this function is a reduction in workspace size, if not using CachedTrace there should never really be a need for this.

# Legacy Functions
## ImportScope
### Summary
This function is the precursor to ScopeTrace, it will import a variety of filetypes and return struct objects that contain the raw data and the file metadata where it is available. This function lacks many optimisations that are present in ScopeTrace, it also is less memory efficient as the data is not accessed at the point of use, rather it is outputted directly from the function into a variable.

### Input Arguments
All given as Name-Value pairs, all optional[^3]

| Name          | DataType      | Default   | Description                                                           |
| ------------- | ------------- | --------- | --------------------------------------------------------------------- |
| "FilePath"    | string        | N/A       | Path to a scope file, can be relative but absolute is more robust.    |
| "Echo"        | logical       | false     | Flag for slightly more verbose mode.
[^3]: If run without arguments ImportScope will launch a file selection window for you to pick the scope file.

## SingleFileType Functions
### Summary/Warning
These functions are **VERY** old, when I coded them i was not nearly as proficient as I am now. Please carefully check the results if you must use these as I cannot guarantee the results will be accurate.
I highly recommend at least using ImportScope(), this whilst legacy should be fine for data import. Ideally you should use ScopeTrace() it is more memory efficient, and contains lots of extra tricks.

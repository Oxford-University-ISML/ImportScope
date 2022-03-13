# ScopeTrace
## Sumary
An object for importing binary oscilloscope files from either Tektronix or LeCroy oscilloscopes found within the ISML Lab. This object will manage storage, summarising metadata, and accessing of raw data for a variety of filetypes. Where file types are not conducive to quick access (.csv and .dat a couple of examples) the object will create binary files to acommpany the raw file, these will allow all future imports to run much quicker.

## Dependencies
None

## Installation
Just download and put it somewhere logical. This package is used by other tools (PDVTrace, PDVAnalysis & LightGate) so youll want it to have a fairly logical path.

## Input arguments
All given as Name-Value pairs, all optional[^1]

| Name          | DataType      | Default      	| Description								|
| ------------- | ------------- | -------------	| -------------								|
| "FilePath"	| string        | N/A           | Path to a scope file, can be relative but absolute is more robust.	|
| "Echo"       	| logical	| false 	| Flag for slightly more verbose mode. 					|
| "CachedTrace" | logical	| false		| Flag for enforce all data is stored in workspace[^2].			|
[^1]: If run without arguments ScopeTrace will launch a file selection window for you to pick the scope file.
[^2]: This is instead of data being read in when needed. Access to data should be very quick even without enabling this (sometimes the first read is slow if filetypes are not binary). You should really only use the if you want the fastest possible access to data and loads of free memory. 

# Legacy Functions
## ImportScope
### Summary
This function is the precursor to ScopeTrace, it will import a variety of filetypes and return struct objects that contain the raw data and the file metadata where it is available. This function lacks many optimisations that are present in ScopeTrace, it also is less memory efficient as the data is not accessed at the point of use, rather it is outputted directly from the function into a variable.

### Input Arguments
All given as Name-Value pairs, all optional[^3]

| Name          | DataType      | Default      	| Description								|
| ------------- | ------------- | -------------	| -------------								|
| "FilePath"	| string        | N/A           | Path to a scope file, can be relative but absolute is more robust.	|
| "Echo"       	| logical	| false 	| Flag for slightly more verbose mode. 					|
[^3]: If run without arguments ImportScope will launch a file selection window for you to pick the scope file.

## SingleFileType Functions
### Summary/Warning
These funtions are **VERY** old, when I (L) coded them i was not nearly as proficient as I am now. Please carefully check the results if you must use these as I cannot garuantee the results will be accurate.
I highly recommend at least using ImportScope(), this whilst legacy should be fine for data import. Ideally you should use ScopeTrace() it is more memory efficient, and contains lots of extra tricks. ScopeTrace() also integrates with LightGate() and PDVAnalysis() tools allowing some very neat workspaces.

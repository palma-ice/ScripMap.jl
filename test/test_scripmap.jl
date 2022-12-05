using NCDatasets


include("src/ScripMap.jl")



# Load a test dataset
ds = NCDataset("data/era5_orography.nc");
era5 = Dict();
era5["lon"] = ds["longitude"][:];
era5["lat"] = ds["latitude"][:];
era5["zs"]  = ds["z"][:][:,:,1] ./ 9.81;
close(ds);
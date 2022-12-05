using NCDatasets


include("src/ScripMap.jl")



# Load a test dataset
ds = NCDataset("data/era5_orography.nc");
era5 = Dict();
era5["lon"] = ds["longitude"][:];
era5["lat"] = ds["latitude"][:];
era5["zs"]  = ds["z"][:][:,:,1] ./ 9.81;
close(ds);


# Load a scrip map for a given domain
# If it exists, it will be loaded.
grid_name = "GRL-16KM";
mp = map_scrip_load("ERA5",grid_name,"data")

# Map a variable to our domain
# Returns the variable and a mask of where interpolation was performed
msk,var = map_scrip_field(mp,"zs",era5["zs"],method="mean");

# Or just return the variable
_,var = map_scrip_field(mp,"zs",era5["zs"],method="mean");

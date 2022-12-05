using NCDatasets
using CairoMakie

include("../src/ScripMap.jl")


# Define target grid name 
grid_name = "GRL-16KM";


begin 

    # Get regional grid file 
    ds = NCDataset("data/"*grid_name*"_REGIONS.nc");
    reg = Dict();
    reg["xc"]  = ds["xc"][:];
    reg["yc"]  = ds["yc"][:];
    reg["x2D"] = ds["x2D"][:];
    reg["y2D"] = ds["y2D"][:];
    reg["lon2D"] = ds["lon2D"][:];
    reg["lat2D"] = ds["lat2D"][:];
    close(ds);

    # Load a global test dataset
    ds = NCDataset("data/era5_orography.nc");
    era5 = Dict();
    era5["lon"] = ds["longitude"][:];
    era5["lat"] = ds["latitude"][:];
    era5["zs"]  = ds["z"][:][:,:,1] ./ 9.81;
    close(ds);

    # Load a scrip map for a given domain
    # If it exists, it will be loaded.

    mp = map_scrip_load("ERA5",grid_name,"data");

    # Map a variable to our domain
    # Returns the variable and a mask of where interpolation was performed
    msk,var = map_scrip_field(mp,"zs",era5["zs"],method="mean");

    # Or just return the variable
    _,var = map_scrip_field(mp,"zs",era5["zs"],method="mean");

end;


## Testing fill method with NearestNeighbors


_,zs = map_scrip_field(mp,"zs",era5["zs"],method="mean");
zs_nan = copy(zs);

kk = findall(zs .< 10.0);
zs_nan[kk] .= NaN;

fill_nearest!(zs_nan;xx=reg["x2D"],yy=reg["y2D"]);

zs_nan[kk] .= NaN;
fill_nearest!(zs_nan);


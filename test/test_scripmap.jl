using NCDatasets
using CairoMakie

include("../src/ScripMap.jl")


# Define target grid name 
grid_name = "GRL-16KM";
grid_dx   = 16.0;

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
    msk,var = map_scrip_field(mp,"zs",era5["zs"];method="mean");

    # Or just return the variable
    _,var = map_scrip_field(mp,"zs",era5["zs"];method="mean");

end;


## Testing fill method with NearestNeighbors


_,zs = map_scrip_field(mp,"zs",era5["zs"];method="mean");

_,zs_filt = map_scrip_field(mp,"zs",era5["zs"];method="mean",
                        filt_method="gaussian",filt_par=[32.0,grid_dx]);

begin
    kk = findall(zs .<= 10.0);
    zs_nan = copy(zs);
    zs_nan[kk] .= NaN;

    kk = findall(zs .<= 10.0);
    zs_nan_wt = copy(zs);
    zs_nan_wt[kk] .= NaN;
    fill_weighted!(zs_nan_wt);

    kk = findall(zs .<= 10.0);
    zs_nan_nn = copy(zs);
    zs_nan_nn[kk] .= NaN;
    #fill_nearest!(zs_nan_nn;xx=reg["x2D"],yy=reg["y2D"]);
    fill_nearest!(zs_nan_nn);
end

begin
    fig = Figure();
    ax1 = Axis(fig[1,1];aspect=DataAspect());
    ax2 = Axis(fig[1,2];aspect=DataAspect());
    ax3 = Axis(fig[1,3];aspect=DataAspect());
    ax4 = Axis(fig[1,4];aspect=DataAspect());
    
    zlim = (10,100);
    heatmap!(ax1,zs,colorrange=zlim)
    heatmap!(ax2,zs_filt,colorrange=zlim)
    heatmap!(ax3,zs_nan_wt,colorrange=zlim)
    hm = heatmap!(ax4,zs_nan_nn,colorrange=zlim)

    # xlim = (0,40);
    # ylim = (10,150);

    # xlims!(ax1,xlim)
    # ylims!(ax1,ylim)
    # xlims!(ax2,xlim)
    # ylims!(ax2,ylim)
    # xlims!(ax3,xlim)
    # ylims!(ax3,ylim)

    Colorbar(fig[1,end+1],hm,height=Relative(2/3))
    fig
end
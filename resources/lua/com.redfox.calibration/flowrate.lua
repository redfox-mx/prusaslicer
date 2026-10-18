local Flowrate = {}
Flowrate.__index = Flowrate

function Flowrate:new(path)
    local flowrate = {}
    setmetatable(flowrate, self)

    flowrate.assetsPath = path
    return flowrate
end

local function load_sample(path, value)
    local name = value >= 0 and tostring(value) or 'm' .. math.abs(value)
    return api.load_stl(path .. '/flowrate_' .. name .. '.stl')
end

local function flow_ratio(value)
    return 1 + (value / 100)
end

function Flowrate:generate(samples, fn)
    local volumes = {}
    local update_fn = fn or flow_ratio

    for idx = 1, #samples do
        local value = samples[idx]
        local mesh = load_sample(self.assetsPath, value)

        table.insert(volumes, {
            type = VolumeType.Solid,
            mesh = mesh,
            params = {
                object_extrusion_ratio = update_fn(value),
                fill_density = 35,
                perimeters = 1,
                top_infill_extrusion_width = 0.48, -- TODO: may % be better?
                solid_infill_extrusion_width = 0.48,
                ironing = false,
                thick_bridges = false,
                extra_perimeters_on_overhangs = false,
                fill_angle = 135,
                gap_fill_enabled = false,
                top_solid_layers = 5,
                top_solid_min_thickness = 0,
                top_fill_pattern = 'monotonic',
                bottom_solid_layers = 2,
                bottom_solid_min_thickness = 0,
            },
        })
    end

    local object = table.remove(volumes, 1)

    object.type = nil
    object.other_volumes = volumes
    object.object_params = {
        layer_height = 0.2,
    }

    api.project:add_object(object)
end

return Flowrate
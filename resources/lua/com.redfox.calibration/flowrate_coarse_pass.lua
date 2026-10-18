info = {
    id = 'com.redfox.calibration.flowrate.coarse',
    type = 'project.plugin',
    title = 'Flow Ratio Pass 1 (coarse)',
    menu = 'Calibration/Flow Ratio/Pass 1 (coarse)',
    params = {}
}

function execute()
    local samples = {
         20,   15,  10,
          5,    0,   -5,
        -20,  -15,  -10,
    }

    local Flowrate = require('flowrate')
    local test = Flowrate:new('assets/flowrate_coarse')

    test:generate(samples)
end

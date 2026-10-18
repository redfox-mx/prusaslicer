info = {
    id = 'com.redfox.calibration.flowrate.fine',
    type = 'project.plugin',
    title = 'Flow Ratio Pass 2 (Fine)',
    menu = 'Calibration/Flow Ratio/Pass 2 (Fine)',
    params = {}
}

function execute()
    local samples = {
        0,
        -1, -2,  -3 ,
        -4, -5,  -6,
        -7, -8,  -9
    }

    local Flowrate = require('flowrate')
    local test = Flowrate:new('assets/flowrate_fine')

    test:generate(samples)
end

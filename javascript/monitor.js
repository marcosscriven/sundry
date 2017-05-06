const chartId = 'signalToNoiseRatio';

function run() {
    $.getScript('https://cdnjs.cloudflare.com/ajax/libs/Chart.js/2.5.0/Chart.min.js').done(
        () => {
            document.body.className = '';
            $("body").html('<canvas id="' + chartId + '" width="400" height="300"></canvas>');
            getData();
        }
    );
}

function getData() {
    console.log("Getting data.");
    fetch('walk?oids=1.3.6.1.4.1.4491.2.1.20.1.24.1.1').then(x => {
        return x.json();
    }).then(rawData => {
        var data = [];
        for (key in rawData) {
            var value = rawData[key];
            var integerValue = Number(value);
            if(!Number.isNaN(integerValue)) {
                data.push(integerValue/10);
            }
        };
        createChart(data);
    });
}

function createChart(snrData) {
    console.log("Creating chart for data:" + snrData);
    var ctx = document.getElementById(chartId);
    var myChart = new Chart(ctx, {
        type: 'bar',
        data: snrData,
        options: {}
    });
}
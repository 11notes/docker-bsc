var stats = {time:0, missing:0, bps:{n:0, sum:0}};
setInterval(function(){
    if(stats.time <= 0){
        stats.time = new Date().getTime();
        stats.missing = parseInt(eth.syncing.highestBlock - eth.syncing.currentBlock);
    }else{
        var missing = parseInt(eth.syncing.highestBlock - eth.syncing.currentBlock);
        var eta = '';
        if(stats.bps.n > 10){
            var bps = stats.bps.sum/stats.bps.n;
            eta = ' median bps: '+bps.toFixed(2)+', eta: '+(missing/bps/60).toFixed(2)+'min';
        }
        console.log('stats{ missing: '+missing+eta+' }');
        stats.bps.sum += Math.abs(stats.missing - missing)/((new Date().getTime() - stats.time)/1000);
        stats.bps.n++;
        stats.time = new Date().getTime();
        stats.missing = missing;
    }
}, 1000);
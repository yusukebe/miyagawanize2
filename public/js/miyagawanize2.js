$().ready(function(){
    var ws = new WebSocket("ws://localhost:3000/ws");
    ws.onmessage = function (msg) {
        var target = document.getElementById("target");
        target.src = msg.data;
    }
    var video = $("#live").get()[0];
    var canvas = $("#canvas");
    var ctx = canvas.get()[0].getContext('2d');
    navigator.webkitGetUserMedia(
        { video : true },
        function(stream) {
            video.src = window.webkitURL.createObjectURL(stream);
        },
        function(err) {
            console.log("Unable to get video stream!");
        }
    );
    timer = setInterval(
        function () {
            ctx.drawImage(video, 0, 0, 400, 300);
            var data = canvas.get()[0].toDataURL('image/jpeg');
            ws.send(data);
        }, 500
    );
});


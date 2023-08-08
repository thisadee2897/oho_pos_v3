const app = require('./app');
const port = process.env.PORT || 5600;
const { Server } = require("socket.io");
const http = require('http').createServer(app);
const io = new Server(http);

// io.on("connection", socket => {
//     app.io = socket;
//     console.log('Connected');
// });

http.listen(port,()=>{
    console.log('Server is runnig on port : ' + port);
});




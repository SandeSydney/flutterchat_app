// This file houses the server code

// map of the app's users
/**
 * the user descriptor object shall be in the form
 * { userName : "", password : "" }
 */
const users = {};

// map for the app's rooms
// the room descriptor objects will be in the form
/* 
    { roomName : "", description : "", maxPeople : 99,
    private : true|false, creator : "",
    users : [
    <username> : { userName : "" }, ...
    ]
    }
*/
const rooms = {};

/**
 * create the socket.io object: creates a HTTP server
 */
const io = require("socket.io")(
    require("http").createServer(
        function(){}
    ).listen(80)
);

// code on how the socket.io server should respond to connection messages
io.on("connection", io =>{
    console.log("\n\nConnection Established with a client");
});

/**
 * Upon submission of the userName and password credentials
 * the following code is used by the server for validation
 * and if the user is new, a newUser is created and a broadcast sent
 */
io.on("validate",(inData, inCallback)=>{
    const user = users[inData.userName];
    if (user) {
        if (user.password === inData.password) {
            inCallback({status:"ok"});
        } else{
            inCallback({status:"fail"});
        }
    } else{
        users[inData.userName] = inData;
        io.broadcast.emit("newUser", users);
        inCallback({status: "created"});
    }
});

/**
 * Upon validation, a user can create rooms to chat 
 * this is supported by the server via the call below:
 * checks is the room exists and if not, a new one is created
 */
io.on("create",(inData, inCallback)=>{
    if (rooms[inData.roomName]) {
        inCallback({status:"exists"});
    } else{
        inData.users = {};
        rooms[inData.roomName] = inData;
        io.broadcast.emit("created",rooms);
        inCallback({status:"created", rooms: rooms});
    }
});

/**
 * Since we have a message to create rooms, this message shall be 
 * used to list all the rooms
 */
io.on("listRooms", (inData, inCallback)=>{
    inCallback(rooms);
});

/**
 * The following is a server message to get the list of users
 */
io.on("listUsers", (inData, inCallback)=>{
    inCallback(users);
});

/**
 * Code to allow the user to join or enter a room. 
 * join message handler
 */
io.on("join", (inData, inCallback)=>{
    // get reference to the room descriptor object
    const room = rooms[inData.roomName];

    // check to see if the room is already full
    if (Object.keys(room.users).length >= rooms.maxPeople) {
        inCallback({status:"full"});
    } else{
        rooms.users[inData.userName] = users[inData.userName];
        io.broadcast.emit("joined", room);
        inCallback({status:"joined",room:room});
    }
});

/**
 * Post message handler allows users to post messages to the groups
 */
io.on("post", (inData, inCallback)=>{
    io.broadcast.emit("posted", inData);
    inCallback({status: "ok"});
});

/**
 * Invite message handler enables a user to invite other users
 */
io.on("invite", (inData, inCallback)=>{
    io.broadcast.emit("invited", inData);
    inCallback({status: "ok"});
});

/**
 * Message handler to enable a user leave a room
 */
io.on("leave", (inData, inCallback)=>{
    const room = rooms[inData.roomName];
    delete room.users[inData.userName];
    io.broadcast.emit("left", room);
    inCallback({status: "ok"});
});

/**
 * message handler to close the room created by the user
 */
io.on("close", (inData, inCallback)=>{
    delete rooms[inData.roomName];
    io.broadcast.emit(
        "closed", {roomName:inData.roomName, rooms : rooms}
    );
    inCallback(rooms);
});

/**
 * Kicking the user out of the room
 */
io.on("kick", (inData, inCallback)=>{
    const room = rooms[inData.roomName];
    const users = room.users;
    delete users[inData.userName];
    io.broadcast.emit("kicked", room);
    inCallback({status: "ok"});
});
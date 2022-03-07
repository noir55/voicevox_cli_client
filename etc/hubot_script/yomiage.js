// Description:
//    Read the text of the chat aloud.
//

module.exports = (robot) => {
  robot.hear(/.*/, (msg) => {
    //chatmsg += msg.message.text.replace(/[\']/g,'"');
    var obj = {
      channel: msg.envelope.room,
      user: msg.envelope.user.name,
      message: msg.message.text
    }
    json = JSON.stringify(obj);
    //require('child_process').exec( "echo \'" + json + "\' >>/tmp/chat.txt" );
    require('child_process').exec( "echo '" + json + "' | /opt/vvtts/bin/seqread" );
  })
}



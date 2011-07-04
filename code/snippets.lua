

-- determine angle of mouse
mc.rotation = Math.atan2( mc.y -  mouseY,  mc.x - mouseX) / Math.PI * 180 -90;



-- put in tick
dx = object.x - mouseX;
dy = object.y - mouseY;
Radians = Math.atan2(dy, dx);

Projectile.x += Math.cos(Radians) * 5;
Projectile.y += Math.sin(Radians) * 5;





------

import flash.events.Event;
import flash.events.MouseEvent;

var speed:Number = 10;
var bull:Bullet;//represents bullet dynamically adding from library;
var bulletAngle;
addEventListener(Event.ENTER_FRAME, moving);

function moving(e:Event):void 
{
        mc.rotation = Math.atan2( mc.y -  mouseY,  mc.x - mouseX) / Math.PI * 180 -90;
        //mc represents something that should fire the bullet (cannon, soldier etc.)
        //and in my case it is a movieClip placed manually on stage 
}
stage.addEventListener(MouseEvent.CLICK, shot);

function shot(e:MouseEvent):void 
{  
        bull = new Bullet();    //new instance of Bullet        
        addChild(bull);

        bull.x = mc.x
        bull.y = mc.y;
        bull.rotation = (mc.rotation -90)* Math.PI/180;
        bulletAngle = bull.rotation ;
        bull.addEventListener(Event.ENTER_FRAME, movingBull);
		e.updateAfterEvent();
}

function movingBull(e:Event):void 
{
    e.target.x += Math.cos(bulletAngle)*speed;
    e.target.y += Math.sin(bulletAngle)*speed;
}
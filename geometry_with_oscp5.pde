// load the P5 libraries:
import oscP5.*;
import netP5.*;

// create the objects we need for oscp5:
OscP5 oscP5;
NetAddress myRemoteLocation;
//we're sending: /test
//               /time
//               /score



int width=500;
int height=500;
int gameTime=30; // How long the game goes for (seconds)

//Values for background lines
float line1Height=height*.4;
float line2Height=height*.6;
float line3Height=height*.8;
float lineStart=width*.02; //10
float space=width*.2; //100

float halfSpace=space*.5;

//Values for background sqaure
float a=width*.02;    //x of background rect - 10  
float b=height*.26;   //y of background rect - 130
float sideAB=width*.14;  //70

//Values for square player
float x=width*.04;    //x of square guy - 20
float y=height*.3;    //y of square guy - 150
float sideXY=width*.1; //50

//Values for circle
float i=width*.2;    //x of corner of  ellipse - 100
float j=height*.32;   //y of corner of ellipse - 160
float sideIJ=width*.08; //40

//Value to move the circle by each time it is pushed
float inc=width*.04; //20

//Other
int sec; //the time since the program begins 
int timeStarted;  //the time when the the player clicks to start the game
int time;  // the time since the game started
int score=0; 
int highSc=0;

int pointsGained = 0; 
int pointsLost = 0; 

float textStart=width*.04; //location where left-aligned text will start
String instructions1; 
String instructions2;
String title= "GEOMETRY"; //game title
String highScore;


//variables for game state
final int START = 1;
final int PLAY = 2;
final int AGAIN = 3;
final int GAME = 4;
int state= START;


//FUNCTIONS:

void background(){
/*This function will make the background of the game: 
black with three white lines going across, a white square where the 
square player starts, and a white circle where the blue circle needs to be pushed.*/
    background(#000000); //black bkg
    strokeWeight(height*.008); //4
    stroke(#ffffff);
    line(lineStart, line1Height, width-space, line1Height); 
    line(space, line2Height, width-lineStart, line2Height);
    line(lineStart, line3Height, width-halfSpace*.5, line3Height);
    strokeWeight(height*.002); //1
    fill(#FFFFFF);
    rect(a,b,sideAB,sideAB);
    fill(#ffffff);
    ellipseMode(CORNER);
    ellipse(width-halfSpace,line3Height-halfSpace,halfSpace,halfSpace); 
}

void displayTimeScore(int sec){ 
//This function will display the timer, the current score and the high score as text in the top left corner.  
    time=sec-timeStarted;
    String t="Time: "+time;
    String s="Score: "+score;
    String to= "Time's Out!";
    
    textSize(height*.028);  //font size 14
    textAlign(LEFT);
    fill(#ffffff); 
      
    //if there is time left, the time will show. Other wise it will display time out.
    if ((time<=gameTime)&&(state==PLAY))     
        text(t,textStart,height*.04); 
    else
        text(to,textStart,height*.04);
    
    OscMessage myMessage = new OscMessage("/time");
    float lfoSpeed = 4.5;
    
    if((time<=gameTime)&&(time>gameTime* .66)&&(state==PLAY))
        myMessage.add(time); //running out of time- sends the time. 
    else
        myMessage.add(lfoSpeed); //running out of time- sends the time.
    oscP5.send(myMessage, myRemoteLocation);
    
    //score will display under time
    text(s,textStart,height*.08);
    highScore="High Score: "+highSc;
    if(state==GAME){ //when the game is over, the high score will turn yellow
      fill(#ffff00);
    }
    text(highScore,textStart,height*.12);
}

void displayInstructions(){
    textSize(height*.028);  //font size 14
    textAlign(CENTER);
    fill(#ffffff); 
    if(state==START){
        instructions1= "Click anywhere to begin.";
        instructions2="You are the square. \n Push as many circles as you can to the end \n by moving the mouse!";
        text(instructions1, width*.5,height*.2);
        text(instructions2, width*.5,height*.3);
    }   
    if((state==PLAY)&&(time<=5)){
        instructions1= "You have " +gameTime+" seconds. Get as many circles as you can to the end!";
        text(instructions1, width*.5,height*.2);
      }
    if (state==AGAIN){
        instructions1= "Click anywhere to try again and beat your score!";
        instructions2="(Press Q on the keyboard if you are done for now)";
        text(instructions1, width*.5,height*.2);
        text(instructions2, width*.5,height*.3);
    } 
}

void displayTitle(){
     if((score+1)%2==1)
         fill(#ffff00);
     else
         fill(#ffffaa);
//  fill(#ffff00);
    textAlign(CENTER);
    textSize(width*.144); //72
     if((state==PLAY)||(state==AGAIN)){ //DISPLAY ON BOTTOM
         text(title, width*.5, height*.95);
     }
     if(state==START){ //DISPLAY IN CENTER
         text(title, width*.5,height*.55);
     }
     if(state==GAME){
        text("GAME OVER!",width*.5,height*.55);
     }
}

void drawSqCirc(){
    fill(#0000ff);      //draw the square guy green
    rect(x,y,sideXY,sideXY);
    fill(#00ff00);      //draw the circle blue
    ellipseMode(CORNER);
    ellipse(i,j,sideIJ,sideIJ);
}

void moveCircle(){
    // Move the circle using the square:
    if((x>=i-sideXY)&&(x<=i-(sideIJ/2))&&(y>j-sideXY)&&(y<j+sideIJ)){
       i+=inc;
    }
    if(i>(width-space)&&(j==line1Height-sideIJ)){
       j=line2Height-sideIJ;
    }
    if((x<=i+sideIJ)&&(x>=i+sideIJ/2)&&(y>=j-sideXY)&&(y<=j+sideIJ)){
       i-=inc;
    }
    if((i<space)&&(j==line2Height-sideIJ)){
       j=line3Height-sideIJ;
    }
}

void positionSqCirc(){
     x=width*.04;    //x of square guy - 20
     y=height*.3;    //y of square guy - 150
     i=width*.2;     //x of corner of  ellipse - 100
     j=height*.32;    //y of corner of ellispe - 160
}

void keepScore(){
  
    OscMessage myMessage = new OscMessage("/score");

    //If the circle makes it to the end, position the circle and square to the beginning and add a point:
    if ((i>=width-sideIJ)&&(j==line3Height-sideIJ)){
        positionSqCirc();
        score+=1;
        pointsGained+=1; 
        if(pointsLost!=0)
          pointsLost-=1; 
     }
     //If the circle goes beyond the boundaries before the end, position and lose a point      
     if( (j!=line3Height-sideIJ &&(i<=0||i>=width-sideIJ)) || (j==line3Height-sideIJ && i<=0) ){
         positionSqCirc();
         score-=1;
         pointsLost+=1;
      }      
    
     myMessage.add(convertGained(pointsGained));
     myMessage.add(convertLost(pointsLost));
     oscP5.send(myMessage, myRemoteLocation);
}

int convertGained(int points){
    int newPoints = 0;
    if (points == 0) 
        newPoints = -200;
    else if(points >8)
        newPoints = 0;
    else if (points == 1)
        newPoints = -45;
    else
        newPoints = 5 + convertGained(points-1);
    return newPoints;
}

int convertLost(int points){
    int newPoints; 
    if (points == 0) 
        newPoints = -200;
    else if(points >=8)
        newPoints = -28;
    else if (points == 1) 
        newPoints = -63;
    else 
        newPoints = 5 + convertLost(points-1);
    return newPoints;
}

void setup (){
    size(width,height);
    // start oscP5:
    oscP5 = new OscP5(this, 12345);
    // "127.0.0.1" = localhost = this computer 
    // 12345 is the port number Max is listening on
    myRemoteLocation = new NetAddress("127.0.0.1", 12345);
}


void draw (){ 
    
 sec=millis()/1000;  //Gets seconds since it started
OscMessage myMessage = new OscMessage("/start");
 switch (state)
 {
   case START:
     myMessage.add(1);
     myMessage.add(8.0);
     background();
     displayInstructions();
     displayTitle();
     break;
   case PLAY:
     myMessage.add(1);
     myMessage.add(24);
      background(); //call background function
      displayTimeScore(sec);  //calls displayTimeScore function and sends it sec 
      displayInstructions();
      displayTitle();
      //WHILE TIME IS LEFT:
      if(time<=gameTime){
          drawSqCirc(); //call function to draw the square and circle
          moveCircle(); //call function for the circle to move when the player "pushes" it
          keepScore(); //keep track of score
      }
      //WHEN TIME IS OUT:
      if(time>gameTime){  
          state=AGAIN;
      }
      break;
   case AGAIN:
     myMessage.add(1);
     myMessage.add(8);
       background();
       if(score>highSc){
         highSc=score;
       }
       displayTimeScore(sec);
       displayTitle();
       displayInstructions();
       break;
   case GAME:
       background();
       displayTimeScore(sec);
       displayTitle();
       myMessage.add(0);
       break;
 }
      oscP5.send(myMessage, myRemoteLocation);
}
   
void mouseMoved() {
    //OscMessage myMessage = new OscMessage("/test");
    x=mouseX;
    y=mouseY;
    //myMessage.add(mouseY/100);
    //oscP5.send(myMessage, myRemoteLocation);
}

void mousePressed(){
  if((state==START)||(state==AGAIN)){
    state=PLAY;
    timeStarted=millis()/1000;
    score=0;
    pointsGained = 0;
    pointsLost = 0;
    positionSqCirc();
  }
}

void keyPressed(){
  if (state==AGAIN){
    if(key=='Q'||key=='q'){
      state=GAME;
    }
  }
}

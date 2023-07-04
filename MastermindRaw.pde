//Processing: Mastermind - (started around 11.04.2023)

//Hinweiß: Die meisten Konsolen-Outputs sind temporär zum debuggen und werden später entfernt.
//         Die Gewinn- und Verlierungsbenachrichtigung in der Konsole gehört allerdings nicht dazu und wird daher nicht entfernt.

// Bildquelle Zurück-Symbol: https://fonts.gstatic.com/s/i/materialicons/backspace/v13/24px.svg

//variable creation
import controlP5.*;
float WindowWidth = width / 1.5;
float WindowHeight = 1000/1.1;
int tries;
int colors;
IntList colorCombination;
int[] currentField;
int[][]gameColorDisplay;
int[][]gameColorFeedback;
boolean stop;
int showRightCombination;
int cLength;
int elementSize;
int triesPlusOne;
int strokeColor;

// functions

//returns a random number list with "colorCount" range and "cLength" length
IntList randomColors(int colorCount, int cLength) {
  IntList rColors = new IntList(colorCount+1);
  for (int i=0; i<cLength; i++) {
    int rColor = (int) random(colorCount)+1;
    while (rColors.hasValue(rColor)) {
      rColor = (int) random(colorCount)+1;
    };
    rColors.set(i, rColor);
  };
  return rColors;
}
//Converts int[] to IntList
int[] ListToArray(IntList list) {
  int[] convertedArray = new int[list.size()+1];
  for (int i=0; i<list.size(); i++) {
    convertedArray[i] = list.get(i);
  }
  return convertedArray;
};
//Converts IntList to int[]
IntList ArrayToList(int[] array) {
  IntList convertedList = new IntList(array.length);
  for (int i=0; i<array.length; i++) {
    convertedList.set(i, array[i]);
  }
  return convertedList;
};
//return List with 2 entries
// 0: Numbers that belong to the colorList, but are not at the right position
// 1: Numbers that are at the right position
int[] analyseMove(IntList realCombination, int[] testCombination) {
  int rightPositionColor = 0;
  int includesColor = 0;
  for (int i = 0; i<realCombination.size(); i++) {
    if (realCombination.get(i) == testCombination[i]) {
      rightPositionColor++;
    } else if (realCombination.hasValue(testCombination[i])) {
      includesColor++;
    }
  }
  return new int[]{rightPositionColor, includesColor};
};
void resetGameColorDisplay() {
  for (int x = 0; x<tries; x++) {
    for (int y = 0; y<cLength; y++) {
      gameColorDisplay[x][y] = -1;
    }
  }
};

//reset gameColorFeedback IntList
void resetGameColorFeedback() {
  for (int x = 0; x<tries; x++) {
    for (int y = 0; y<cLength; y++) {
      gameColorFeedback[x][y] = 0;
    }
  }
};
void gameColorFeedbackFill(int number, int y){
     int feedback = gameColorFeedback[y][number];
     switch(feedback){
      case 0:
      noFill();
      break;
      case 1:
      fill(#ffffff);
      break;
      case 2:
      fill(#000000);
      break;
  }
};

// general setup
void setup() { 

  //initialise variables
  WindowWidth = width / 1.5;
  WindowHeight = 1000/1.1;
  tries = 10;
  colors = 6;
  cLength = 4;
  stop = false;
  showRightCombination = 0;
  currentField = new int[]{0, 0};
  colorCombination = randomColors(colors, cLength);
  triesPlusOne = tries +1;
  elementSize = 60*10/tries;
  // Player's Input Colors - Integer Array
  gameColorDisplay= new int[tries][cLength];

  // Player's guess feedback - Integer Array
  gameColorFeedback = new int[tries][4];
  
  //project configuration
  size(1000, 960);
  ControlP5 cp5;
  cp5 = new ControlP5(this);
  println("Processing: Mastermind");
  resetGameColorDisplay();

  //row generation - buttons
  for (int y=0; y<tries; y++) {
    int rowHeight = int(WindowHeight/triesPlusOne-WindowHeight/triesPlusOne/2+WindowHeight/triesPlusOne*y);
    strokeColor = 255/colors*y;
    colorMode(HSB);
    stroke(0, 100, 50);
    noFill();
    if (y < colors+1) {

      //colored Buttons - GUI
      int buttonX = int(WindowWidth-10-60*5/tries-50);
      int buttonY = rowHeight-(elementSize/2);
      int buttonWidth = elementSize;
      int buttonHeight = elementSize;
      noStroke();
      colorMode(HSB);
      Button colorButton;
      Button removeColor;
      colorButton = new Button(cp5, str(y))
        .setPosition(buttonX, buttonY).setSize(buttonWidth, buttonHeight)
        .setColorBackground(color(strokeColor, 200, 200))
        .setLabel("")
        .setColorForeground(color(strokeColor, 230, 180))
        .setColorActive(color(strokeColor, 230, 230));

      //backspace button
      if (y==colors) {
        PImage backspace;
        backspace = loadImage("round_backspace_white_24dp.png");
        colorButton.remove();
        removeColor = new Button(cp5, "")
          .setPosition(buttonX, buttonY).setSize(buttonWidth, buttonHeight)
          .setColorBackground(color(100, 0, 100))
          .setLabel("")
          .setColorActive(color(100, 0, 130))
          .setColorForeground(color(100, 0, 90))
          .setImage(backspace);

          removeColor.addCallback(new CallbackListener() {
          public void controlEvent(CallbackEvent event) {

          //when reset-button pressed
            
            if (event.getAction() == ControlP5.ACTION_CLICK) {
              if (Integer.valueOf(gameColorDisplay[currentField[0]][cLength-1]) == -1 && currentField[1] > 0) {
                currentField[1] -= 1;
                 gameColorDisplay[currentField[0]][currentField[1]] = -1;
              
              }
            }
          }
        }
        );
      }

     colorButton.addCallback(new CallbackListener() {
        public void controlEvent(CallbackEvent event) {
         
          //when button pressed
          if (event.getAction() == ControlP5.ACTION_CLICK) {
            String colorNumber = event.getController().getName();
            
            //validation - was this color already used?
               if(currentField[1]+1 < cLength){
              for(int i : gameColorDisplay[currentField[0]]){
                if(i == Integer.valueOf(colorNumber) || stop){

                  return;
                }

              }
             
              gameColorDisplay[currentField[0]][currentField[1]] = Integer.valueOf(colorNumber);
              currentField[1] += 1;

            } else {
                for(int i : gameColorDisplay[currentField[0]]){
                if(i == Integer.valueOf(colorNumber) || stop){

                  return;
                }

              }
              
             
              gameColorDisplay[currentField[0]][currentField[1]] = Integer.valueOf(colorNumber);
               
              IntList TempCompareList = new IntList();
            for (int i=0; i<cLength; i++){
              TempCompareList.set(i, gameColorDisplay[currentField[0]][i]+1);
              
            }
            
            int[] result = analyseMove(colorCombination, ListToArray(TempCompareList));
            
          
             //Darstellung des Erbebnisses ( Spielerrückmeldung)
           int[] moddedResult = java.util.Arrays.copyOf(result, 2);
            for (int i=0; i<4; i++){
             
              if(moddedResult[0] > 0){
              gameColorFeedback[currentField[0]][i] = 2;
              moddedResult[0] = moddedResult[0]-1
              ;
            } else if(moddedResult[1] > 0){
              gameColorFeedback[currentField[0]][i] = 1;
              moddedResult[1] = moddedResult[1]-1 ;
              
            } else {
              gameColorFeedback[currentField[0]][i] = 0;
              
            }
            
            }
            //Ende der Spieler Rückmeldung
            
            //Gewinnüberprüfung
            if(result[0] == cLength) {
              println("Du hast gewonnen!");
              stop = true;
            } else if(tries-1 == currentField[0]) {

              println("Du hast leider verloren!");
              stop = true;
              showRightCombination = 1;
            } else {
              currentField[0] = currentField[0]+1;
              currentField[1] = 0;


            }
            
            }
          }
        }
      }
      );

      noFill();
      stroke(strokeColor, 300, 255);
    }
  }
}

//scene updating method
void draw() {
  clear();
  colorMode(HSB);
  //fullScreen();
  fill(#bbbbbb);
  rect(0, 0, 1000, 960);
  noFill();

  //row generation - circles
  for (int y=0; y<tries; y++) {
    strokeColor = 255/tries*y;
    colorMode(HSB);
    stroke(0, 100, 50); 

    //guessed colors circles
    for (int i=0; i<cLength; i++) {
      noFill();
      if (gameColorDisplay[y][i] != -1) {
        fill(255/colors*gameColorDisplay[y][i], 200, 200);
      };
      circle((WindowWidth-100)/(cLength+1)*i+(WindowWidth-100)/10, WindowHeight/triesPlusOne-WindowHeight/triesPlusOne/2+WindowHeight/triesPlusOne*y, elementSize);
    }
  noFill();
    //color feedback display
    int rowHeight = int(WindowHeight/triesPlusOne-WindowHeight/triesPlusOne/2+WindowHeight/triesPlusOne*y);
    gameColorFeedbackFill(0, y);
    circle(WindowWidth-WindowWidth/4, rowHeight-WindowHeight/66*12/tries, 25*10/tries);
    gameColorFeedbackFill(1, y);
    circle(WindowWidth-WindowWidth/4+30, rowHeight-WindowHeight/66*12/tries, 25*10/tries);
    gameColorFeedbackFill(2, y);
    circle(WindowWidth-WindowWidth/4, rowHeight-WindowHeight/66+WindowHeight/33*12/tries, 25*10/tries);
    gameColorFeedbackFill(3, y);
    circle(WindowWidth-WindowWidth/4+30, rowHeight-WindowHeight/66+WindowHeight/33*12/tries, 25*10/tries);

    //numbers for the rows
    fill(#555555);
    text(y+1, WindowWidth+50, rowHeight);
    noFill();
    if(showRightCombination == 1){
    int height = int(WindowHeight/triesPlusOne-WindowHeight/triesPlusOne/2+WindowHeight*0.9);

        fill(255/colors*colorCombination.get(y%4), 200, 200);
      circle((WindowWidth-100)/(cLength+1)*(y%4)+(WindowWidth-100)/10, height, elementSize);
  }}
  
  //end of row loop
}

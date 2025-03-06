void setup() {
  size(1760, 960);
  Data = new ArrayList();
}

float a = 1, b = 1;
ArrayList<PVector>Data;
boolean flag = true;

void draw() {
  background(255);

  fill(0);
  textSize(60);
  text("ab-space", 330, 60);
  text("xy-space", 1230, 60);

  stroke(155);
  strokeWeight(1);
  for (int i = 0; i < 10; i++) {
    line(30 + 80*i, 80, 30 + 80*i, 880);
    line(30, 80 + 80*i, 830, 80 + 80*i);
  }
  stroke(0);
  strokeWeight(2);
  line(430, 80, 430, 880);
  line(30, 480, 830, 480);

  stroke(155);
  strokeWeight(1);
  for (int i = 0; i < 10; i++) {
    line(930 + 80*i, 80, 930 + 80*i, 880);
    line(930, 80 + 80*i, 1730, 80 + 80*i);
  }
  stroke(0);
  strokeWeight(2);
  line(1330, 80, 1330, 880);
  line(930, 480, 1730, 480);

  if (Data.size() > 1) {
    float A = (xy_mean - x_mean*y_mean)/(xx_mean-x_mean*x_mean);
    float B = y_mean - A*x_mean;
    fill(255, 255, 0);
    ellipse(430+80*A, 480-80*B, 25, 25);

    for (float ax = -5; ax <= 5; ax+=0.03) {
      for (float by = -5; by <= 5; by+=0.03) {
        if ((Loss(ax, by) % 10 < 0.5 || Loss(ax, by) % 10 > 9.5) && 5 < Loss(ax, by) && Loss(ax, by) < 50) {
          fill(0, 0, 255);
          noStroke();
          ellipse(430+80*ax, 480-80*by, 5, 5);
        }
      }
    }

    /*
    for (float loss = 5; loss < 30; loss += 5) {
     PVector CV = findLossC(loss);
     if (abs(Loss(CV.x, CV.y)-loss) > 0.1)continue;
     float theta = 0;
     PVector GV = GradLoss(CV.x, CV.y);
     GV.setMag(0.1);
     while (theta <= 2*PI) {
     PVector update = new PVector(-GV.y, GV.x);
     update.sub(GV.mult(0.01));
     PVector nGV = GradLoss(CV.x-GV.y, CV.y+GV.x);
     line(430 + CV.x*80, 480 - 80*CV.y, 430 + 80*(CV.x+update.x), 480 - 80 * (CV.y+update.y));
     CV.add(update);
     theta += abs(acos(GV.dot(nGV)/(nGV.mag()*GV.mag())));
     GV.x = nGV.x;
     GV.y = nGV.y;
     GV.setMag(0.1);
     }
     line(430 + CV.x*80, 480 - 80*CV.y, 430 + 80*(CV.x-GV.y), 480 - 80 * (CV.y+GV.x));
     }
     */
  }

  fill(255, 0, 0);
  noStroke();
  ellipse(430+80*a, 480-80*b, 20, 20);

  stroke(255, 0, 0);
  strokeWeight(4);
  float dx = 0.1;
  for (float x = 930; x < 1730; x += dx) {
    //line(930, 480-(a*(930-1330)/80 + b)*80, 1730, 480-(a*(1730-1330)/80 + b)*80);
    if (max(480-(a*(x-1330)/80 + b)*80, 480-(a*(x+dx-1330)/80 + b)*80) > 880 || min(480-(a*(x-1330)/80 + b)*80, 480-(a*(x+dx-1330)/80 + b)*80) < 80) {
      continue;
    }
    if (flag)line(x, 480-(a*(x-1330)/80 + b)*80, x+dx, 480-(a*(x+dx-1330)/80 + b)*80);
  }

  for (int i = 0; i < Data.size(); i++) {
    float X = Data.get(i).x*80+1330;
    float Y = -Data.get(i).y*80+480;
    fill(0, 0, 255);
    noStroke();
    if (dist(X, Y, mouseX, mouseY) < 30) {
      stroke(0, 255, 255);
    }
    ellipse(X, Y, 15, 15);
  }

  noFill();
  stroke(0);
  strokeWeight(5);
  rect(30, 80, 800, 800);
  rect(930, 80, 800, 800);
}

void mouseReleased() {
  if (mouseButton == LEFT) {
    if (930 <= mouseX && mouseX <= 1730 && 80 <= mouseY && mouseY <= 880) {
      float sampleX = (mouseX - 1330)/80.0;
      float sampleY = -(mouseY - 480)/80.0;
      Data.add(new PVector(sampleX, sampleY));
      meanCache();
    }
  }
  if (mouseButton == RIGHT) {
    ArrayList<Integer>  DList = new ArrayList();
    for (int i = 0; i < Data.size(); i++) {
      float X = Data.get(i).x*80+1330;
      float Y = -Data.get(i).y*80+480;
      if (dist(X, Y, mouseX, mouseY) < 30) {
        DList.add(i);
      }
    }
    for (int i = 0; i < DList.size(); i++) {
      Data.remove((int)DList.get(i));
      meanCache();
    }
  }
}

float x_mean = 0;
float y_mean = 0;
float xx_mean = 0;
float xy_mean = 0;
float yy_mean = 0;
void meanCache() {
  x_mean = 0;
  y_mean = 0;
  xx_mean = 0;
  xy_mean = 0;
  yy_mean = 0;
  if (Data.size() == 0) {
    return;
  }
  for (int i = 0; i < Data.size(); i++) {
    x_mean += Data.get(i).x;
    y_mean += Data.get(i).y;
    xx_mean += Data.get(i).x*Data.get(i).x;
    xy_mean += Data.get(i).x*Data.get(i).y;
    yy_mean += Data.get(i).y*Data.get(i).y;
  }
  x_mean /= Data.size();
  y_mean /= Data.size();
  xx_mean /= Data.size();
  xy_mean /= Data.size();
  yy_mean /= Data.size();
}

float Loss(float a, float b) {
  return xx_mean*a*a+2*x_mean*a*b+b*b-2*xy_mean*a-2*y_mean*b+yy_mean;
}
PVector GradLoss(float a, float b) {
  return new PVector(2*(xx_mean*a+x_mean*b-xy_mean), 2*(x_mean*a+b-y_mean));
}
PVector findLossC(float c) {
  float A = random(-5, 5), B = random(-5, 5);
  int cnt = 0;
  while (abs(Loss(A, B)-c) > 0.01 && cnt < 1000) {
    cnt ++;
    PVector V = GradLoss(A, B);
    if (Loss(A, B) < c) {
      A += 0.05*V.x;
      B += 0.05*V.y;
    } else {
      A -= 0.05*V.x;
      B -= 0.05*V.y;
    }
  }
  return new PVector(A, B);
}


void mouseDragged() {
  if (30 <= mouseX && mouseX <= 830 && 80 <= mouseY && mouseY <= 880) {
    a = (mouseX - 430)/80.0;
    b = -(mouseY - 480)/80.0;
  }
}

void keyReleased() {
  if (key == ' ') {
    flag = !flag;
  }
}

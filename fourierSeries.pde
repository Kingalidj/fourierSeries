int nPoints = 1000;
int steps = 10;
int lineWeight = 2;
int maxF = 50;
int minF = 5;
int nF = round(random(2, 5));

float [] graph = generateGraph(nPoints);
void setup() {
	size(1200, 1200);
}

int iteration = 0;
float [] fft = new float[(maxF + 10) * steps];
float [] peaks;
void draw() {
	if (iteration < (maxF + 10) * steps) {
		background(0);
		showGraph(graph, 100, 200, 2 * width / 3, 100);
		PVector [] transformed = transform(graph, (float) iteration / steps);
		showTransform(transformed, 300, 600, 100);
		PVector center = findCenter(transformed, 300, 600, 100);
		fft[iteration] = center.x;
		showGraph(fft, 100, 1000, 2 * width / 3, 100);
		peaks = findPeak(fft, 100, 1000, 2 * width / 3, 100);
		iteration += 1;
	} else { 
		println(peaks);
		noLoop();
	}
}

float [] generateGraph(int size)  {
	float [] graph = new float[size];
	for (int j = 0; j < nF; j++) {
		float f = random(minF * PI, maxF * PI);
		println(round(f / PI));
		for (int i = 0; i < size; i++) {
			float time = map(i, 0, size - 1, 0, f);
			graph[i] += sin(time);
		}
	}
	return graph;
}

void showGraph(float [] graph, float x, float y, float w, float scalar) {
	float maxVal = MIN_FLOAT;
	float minVal = MAX_FLOAT;
	for (float f : graph) {
		if (f > maxVal)maxVal = f;
		if (f < minVal)minVal = f;
	}
	float dx = w / graph.length;
	stroke(255);
	strokeWeight(lineWeight);
	for (int i = 1; i < graph.length; i++) {
		float prev = map(graph[i - 1], minVal, maxVal, -1, 1);
		float current = map(graph[i], minVal, maxVal, -1, 1);
		line(dx * (i - 1) + x, y - prev * scalar, dx * i + x, y - current * scalar);
	}
}

void showTransform(PVector [] graph, float x, float y, float scalar) {
	float minL = MAX_FLOAT;
	float maxL = MIN_FLOAT;
	for (PVector p : graph) {
		if (p.mag() > maxL)maxL = p.mag();
		if (p.mag() < minL)minL = p.mag();
	}

	strokeWeight(lineWeight);
	stroke(255);
	for (int i = 1; i < graph.length; i++) {
		PVector p1 = graph[i - 1].copy();
		PVector p2 = graph[i].copy();
		float l1 = map(p1.mag(), minL, maxL, 0, 1);
		float l2 = map(p2.mag(), minL, maxL, 0, 1);
		p1.setMag(l1);
		p2.setMag(l2);
		p1.mult(scalar);
		p2.mult(scalar);
		line(x + p1.x, y + p1.y, x + p2.x, y + p2.y);
	}
}

float [] findPeak(float [] graph, float x, float y, float w, float scalar) {
	float maxVal = MIN_FLOAT;
	float minVal = MAX_FLOAT;
	for (float f : graph) {
		if (f > maxVal)maxVal = f;
		if (f < minVal)minVal = f;
	}

	int peak = 0;
	float mid = (maxVal + minVal) / 2;
	ArrayList <Integer> peaks = new ArrayList <Integer>();
	for (int i = 1; i < graph.length - 1; i++) {
		if (graph[i] > mid && graph[i] > graph[i - 1] && graph[i] > graph[i + 1])peaks.add(i);
	}

	float dx = w / graph.length;
	fill(200, 0, 0);
	noStroke();
	for (int i : peaks) {
		float val = map(graph[i], minVal, maxVal, -1, 1);
		ellipse(dx * i + x, y - val * scalar, 10, 10);
	}
	float [] peakArr = new float[peaks.size()];
	for (int i = 0; i < peaks.size(); i++)peakArr[i] = peaks.get(i) / steps;
	return peakArr;
}

PVector [] transform(float [] graph, float n) {
	PVector [] transformations = new PVector[graph.length];
	for (int i = 1; i < graph.length; i++) {
		float time1 = map(i - 1, 0, graph.length - 1, 0, n * PI);
		float time2 = map(i, 0, graph.length - 1, 0, n * PI);
		imgNum num1 = new imgNum(1);
		imgNum num2 = new imgNum(1);
		num1.eExp(time1);
		num2.eExp(time2);
		num1.mult(graph[i - 1]);
		num2.mult(graph[i]);
		noStroke();
		fill(255);
		transformations[i - 1] = num1.num.copy();
		transformations[i] = num2.num.copy();
	}
	return transformations;
}

PVector findCenter(PVector [] graph, float x, float y, float scalar) {
	PVector sum = new PVector(0, 0);
	for (PVector p : graph)sum.add(p);
	sum.div(graph.length);
	noStroke();
	fill(200, 0, 0);
	ellipse(sum.x * scalar + x, sum.y * scalar + y, scalar / 10, scalar / 10);
	return sum;
}

class imgNum {
	PVector num;

	imgNum(float len) {
		num = new PVector(1, 1);
		num.setMag(len);
	}

	void eExp(float angle) {
		angle -= PI / 2;
		float len = num.mag();
		num = PVector.fromAngle(angle);
		num.setMag(len);
	}

	void mult(float n) {
		num.mult(n);
	}
}

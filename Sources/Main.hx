package;

import kha.Color;
import kha.Framebuffer;
import kha.Image;
import kha.graphics4.FragmentShader;
import kha.graphics4.IndexBuffer;
import kha.graphics4.PipelineState;
import kha.graphics4.TextureFormat;
import kha.graphics4.Usage;
import kha.graphics4.VertexBuffer;
import kha.graphics4.VertexData;
import kha.graphics4.VertexStructure;
import kha.Shaders;
import kha.System;
import kha.math.FastVector3;
import kha.math.FastVector4;

class Main {
	private static var pipeline: PipelineState;
	private static var vertices: VertexBuffer;
	private static var indices: IndexBuffer;
	private static var texunit: kha.graphics4.TextureUnit;
	private static var color: kha.graphics4.ConstantLocation;
	private static var numPoints:Int; // points around a circle 200 lines
	private static var multip:Float; // somethimg times table
	private static var limit:Float;
	private static var forward:Bool;
	
	private static function calcVertices(vb:VertexBuffer)
	{
		var v = vb.lock();
		// 200 line segments
		var k1 = (1.0 / numPoints) * (2.0 * Math.PI); // angle radians
		var linewd = 1.0 / (numPoints >> 4);
		for (i in 0...numPoints) {
			var j = i * 12;
			var k = (i + 1) * k1;
			var x = Math.cos(k); // points
			var y = Math.sin(k); // on a unit circle
			var dx = Math.cos(k + (k1 * linewd));
			var dy = Math.sin(k + (k1 * linewd));
			v.set(j, x);
			v.set(j + 1, y);
			v.set(j + 2, 0.5);
			v.set(j + 3, dx);
			v.set(j + 4, dy);
			v.set(j + 5, 0.5);
			k = (k * multip);
			x = Math.cos(k);
			y = Math.sin(k);
			dx = Math.cos(k - (k1 * linewd));
			dy = Math.sin(k - (k1 * linewd));
			v.set(j + 6, x);
			v.set(j + 7, y);
			v.set(j + 8, 0.5);
			v.set(j + 9, dx);
			v.set(j + 10, dy);
			v.set(j + 11, 0.5);
		}
		vb.unlock();
	}

	private static function calcIndices(ib:IndexBuffer)
	{
		var i = ib.lock();
		// 200 line segments
		for (k in 0...numPoints) {
			var j = k * 6; // every point has a line with 6 indices
			var n = k * 4; // points per line
			i[j] = n;
			i[j + 1] = n + 2;
			i[j + 2] = n + 1;
			// second trinamgle
			i[j + 3] = n + 1;
			i[j + 4] = n + 2;
			i[j + 5] = n + 3;
		}
		ib.unlock();
	}

	public static function main(): Void {
		System.start({title: "ComputeShader", width: 800, height: 600}, function (win:kha.Window) {
			// texture = Image.create(512, 512, TextureFormat.RGBA64);
			
			var structure = new VertexStructure();
			structure.add("pos", VertexData.Float3);
			// structure.add("tex", VertexData.Float2);
			
			pipeline = new PipelineState();
			pipeline.inputLayout = [structure];
			pipeline.vertexShader = Shaders.shader_vert;
			pipeline.fragmentShader = Shaders.shader_frag;
			pipeline.compile();
			
			color = pipeline.getConstantLocation("col");

			numPoints = 200;
			multip = 1.2;
			limit = 50.0;
			forward = true;
			vertices = new VertexBuffer(numPoints * 4, structure, Usage.DynamicUsage);
			calcVertices(vertices);
			
			indices = new IndexBuffer(numPoints * 6, Usage.StaticUsage);
			calcIndices(indices);

			System.notifyOnFrames(render);
		});
	}

	private static function render(frame: Array<Framebuffer>): Void {
		var g = frame[0].g4;
		g.begin();
		g.clear(Color.Black);
		
		g.setPipeline(pipeline);
		g.setFloat3(color, 0.2, 0.1, 0.8);
		g.setVertexBuffer(vertices);
		g.setIndexBuffer(indices);
		g.drawIndexedVertices();
		g.end();

		multip += (forward ? 0.005 : -0.005);
		if (multip > limit || multip < 1.1) forward = !forward;
		calcVertices(vertices);
	}
}

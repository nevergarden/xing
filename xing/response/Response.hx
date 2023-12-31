package xing.response;

class Response {
	private var status : Int;
	private var body : haxe.io.Bytes;
	private var headers : Map<String,String>;
	private var cookies : Map<String, String>;
	private var output : haxe.io.Output;

	public static function fromOutput(output:haxe.io.Output):Response {
		return new Response(output);
	}

	public static function notFound(output:haxe.io.Output):Void {
		var res : Response = new Response(output);
		res.status = 404;
		res.body = haxe.io.Bytes.ofString("<body><center><h1>404 NotFound</h1></center></body>");
		res.send();
	}

	function new(output:haxe.io.Output) {
		this.output = output;
		this.status = 200;
		this.body = haxe.io.Bytes.ofString("");
		this.headers = new Map<String, String>();
		this.cookies = new Map<String, String>();
	}

	public function addHeader(name:String, value:String):Void {
		this.headers.set(name, value);
	}

	public function setBody(body:String):Void {
		this.body = haxe.io.Bytes.ofString(body);
	}

	public function setBytes(b:haxe.io.Bytes):Void {
		this.body = b;
	}

	public function send():Void {
		this.output.write(getResponse());
		this.output.writeBytes(this.body, 0, this.body.length);
		this.output.writeString("\r\n");
		this.output.flush();
	}

	function getResponse():haxe.io.Bytes {
		var headersString = "";
		for(hKey=>hValue in headers) {
			headersString += '${hKey}: ${hValue}\r\n';
		}

		var statusCode : String = switch (status) {
			case 100: "Continue";
			case 101: "Switching Protocols";
			case 102: "Processing";
			case 103: "Early Hints";
			case 200: "OK";
			default: "Unknown";
		}
		
		return haxe.io.Bytes.ofString('HTTP/1.1 ${status} ${statusCode}\r\n${headersString}\r\n');
	}
}
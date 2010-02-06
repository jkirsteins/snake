package
{
    import org.flixel.*;
    import mx.rpc.http.*;
    import mx.rpc.events.*;

	public class Score
	{
        public static function get TYPE_CLASSIC(): uint { return 1; }
        public static function get TYPE_AMAZO(): uint { return 2; }
        public static function get BACKEND_URL(): String 
        { 
            return "http://janiskirsteins.org/snake.php"; 
        }

        public static function submit_score(name: String, score: uint, type: uint): void
        {
            var transport: HTTPService = new HTTPService();

            transport.url = Score.BACKEND_URL;
            transport.method = "POST";
            transport.resultFormat = "text";

            transport.addEventListener("result", 
                    function (event: ResultEvent): void
                    {
                        FlxG.log("Result: ");
                        FlxG.log(event.result);
                    });
            transport.addEventListener("fault",
                    function (event: FaultEvent): void 
                    {
                        var faultstring: String = event.fault.faultString;
                        FlxG.log("Could not submit: " + faultstring);
                    });
            transport.send({
                name: name, 
                score: score,
                game_type: type });
            FlxG.log('High score information sent');
        }
	}
}

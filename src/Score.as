package
{
    import org.flixel.*;
    import json.*;
    import mx.rpc.http.*;
    import mx.rpc.events.*;

	public class Score
	{
        public static function get ACTION_SUBMIT(): String { return 'submit'; }
        public static function get ACTION_FETCH(): String { return 'fetch'; }

        public static function get TYPE_CLASSIC(): uint { return 1; }
        public static function get TYPE_AMAZO(): uint { return 2; }
        public static function get BACKEND_URL(): String 
        { 
            return "http://janiskirsteins.org/snake.php"; 
        }

        static public function check(type: uint, score: uint): Boolean
        {
            for (var i: uint = 1; i <= 10; i++)
            {
                var prev: Object = HallOfFameState.scores[type][String(i)];
                if (prev["score"] < score)
                {
                    return true;
                }
            }
            return false;
        }

        public static function fetch_scores(type: uint, callback: Function): void
        {
            var transport: HTTPService = new HTTPService();

            transport.url = Score.BACKEND_URL;
            transport.method = "POST";
            transport.resultFormat = "text";

            transport.addEventListener("result", 
                    function (event: ResultEvent): void
                    {
                        callback(type, JSON.decode(String(event.result)));
                    });
            transport.addEventListener("fault",
                    function (event: FaultEvent): void 
                    {
                        var faultstring: String = event.fault.faultString;
                        FlxG.log("Could not fetch: " + faultstring);
                    });
            transport.send({
                action: Score.ACTION_FETCH,
                game_type: type });
            FlxG.log('High score list request sent');
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
                action: Score.ACTION_SUBMIT,
                game_type: type });
            FlxG.log('High score information sent');



            var scores: Object = HallOfFameState.scores;

            for (var i: uint = 1; i <= 10; i++)
            {
                var prev: Object = scores[type][String(i)];
                if (prev["score"] < score)
                {
                    for (var j: uint = 10; j > i; j--)
                    {
                        scores[type][String(j)] = scores[type][String(j-1)];
                    }

                    if (name.length < 8)
                    {
                        for (var z: uint = 0; z < 8 - name.length; z++)
                            name = " " + name;
                    }

                    scores[type][String(i)] = 
                    {
                        'name': name,
                        'score': score,
                        'created_at': 'None'
                    }
                    HallOfFameState.onScoreLoad(type, scores[type]);
                    FlxG.log("Local high score list updated - breaking");
                    return;
                }
            }
        }
	}
}

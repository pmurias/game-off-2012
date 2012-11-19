package game.commands {
    import game.GameContext;
	/**
     * ...
     * @author mosowski
     */
    public class Commander {
        private var gameCtx:GameContext;
        private var commands:Vector.<Command>;
        private var commandIndex:int;
        private var frameNumber:int;

        public function Commander(_gameCtx:GameContext) {
            gameCtx = _gameCtx;
            commands = new Vector.<Command>();
            commandIndex = 0;
            frameNumber = 0;
        }

        public function queueCommand(command:Command):void {
            command.frameNumber = frameNumber;
            commands.push(command);
        }

        public function tick():void {
            while (commandIndex < commands.length && commands[commandIndex].frameNumber <= frameNumber) {
                commands[commandIndex].execute(gameCtx);
                commandIndex++;
            }
            frameNumber++;
        }

        public function reset():void {
            commandIndex = 0;
            frameNumber = 0;
        }

    }

}
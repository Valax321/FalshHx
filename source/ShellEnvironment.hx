using haxe.ds.GenericStack;
using haxe.Json;
using sys.FileSystem;
using sys.io.File;
using haxe.io.Path;

/**
Main controller class for the shell.
**/
class ShellEnvironment
{
    /**
    The global instance of the shell
    **/
    public static var instance(default, null) = new ShellEnvironment();

    /*
    For now, we're doing this manually again.
    Ideally we'd find all types implementing BuiltinCommand (reflection isn't as robust as in C#)
    and instantiate that way, but for now this will have to do.
    */
    private var builtinCommands = 
    [
        "cd" => new ChangeDirectoryCommand()
    ];

    private var commandHistory = new GenericStack<String>(); //Haxe doesn't have a direct equivalent for Queue<>
    private var maxHistory = 20;

    private function new() {}

    /**
    Runs the shell
    **/
    public function run()
    {
        loadConfig();
        setupPrompt();
    }

    /**
    Loads the shell config file
    **/
    private function loadConfig()
    {
        var cfgPath = getConfigPath();
        if (FileSystem.exists(cfgPath))
        {
            var cfg: Dynamic = Json.parse(File.getContent(cfgPath));
            maxHistory = cfg.historySize;
        }
    }

    /**
    Sets up the prompt
    **/
    private function setupPrompt()
    {
        println("Falsh Shell (C) Andrew Castillo 2018", Yellow);
    }

    /**
    Gets the path to the config file.
    On windows, it is %localappdata%/falsh/falsh_config.json
    On Unix, it is ~/.falsh/falsh_config.json
    **/
    private function getConfigPath()
    {        
        #if WINDOWS
        return Path.join([Sys.getEnv("localappdata"), "falsh", "falsh_config.json"]);
        #else
        return Path.join(["~", ".falsh", "falsh_config.json"]);
        #end
    }

    /**
    Checks if the specified builtin command exists.
    @param commandName The command name to check for existence
    **/
    public inline function doesBuiltinCommandExist(commandName: String)
    {
        return builtinCommands.exists(commandName);
    }

    /**
    Executes the specified builtin command, if it exists. 
    If not, nothing happens.
    @param commandName The command name to run if it exists.
    @param args List of arguments to pass to the command (like Sys.args for this command only)
    **/
    private function executeBuiltinCommand(commandName: String, args: Array<String>)
    {
        if (doesBuiltinCommandExist(commandName))
        {
            builtinCommands.get(commandName).exec(args);
        }
    }

    /**
    Prints text to the terminal, with an appended newline.
    @param msg The message to print
    @param color Optional ANSI colour
    **/
    public function println(msg: String, ?color: ANSIColor)
    {
        if (color == null) color = White;
        Sys.println(msg);
    }

    /**
    Prints text to the terminal.
    @param msg The message to print
    @param color Optional ANSI colour
    **/
    public function print(msg: String, ?color: ANSIColor)
    {
        if (color == null) color = White;
        Sys.print(msg);
    }
}
using haxe.ds.GenericStack;
using haxe.Json;
using hx.files.File;
using hx.files.Path;
using hx.files.Dir;
using hx.strings.StringBuilder;
using haxe.Utf8;

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

    private var wantsToQuit = false;

    /**
    Runs the shell
    **/
    public function run()
    {
        loadConfig();
        setupPrompt();

        while (!wantsToQuit)
        {
            processInput();
        }
    }

    /**
    Loads the shell config file
    **/
    private function loadConfig()
    {
        var cfgPath = getConfigPath();
        if (cfgPath.exists())
        {
            var cfg: Dynamic = Json.parse(File.of(cfgPath).readAsString());
            maxHistory = cfg.historySize;
        }
    }

    /**
    Sets up the prompt
    **/
    private function setupPrompt()
    {
        println("Falsh Shell (C) Andrew Castillo 2018", Yellow);
        println('History size: ${maxHistory}');
    }

    /**
    Gets the path to the config file.
    On windows, it is %localappdata%/falsh/falsh_config.json
    On Unix, it is ~/.falsh/falsh_config.json
    **/
    private function getConfigPath()
    {        
        #if windows
        return Path.join([Sys.getEnv("localappdata"), "falsh", "falsh_config.json"]);
        #else
        return Path.of("~/.falsh/falsh_config.json");
        #end
    }

    private function getUserName()
    {
        #if windows
        return Sys.getEnv("username");
        #else
        return Sys.getEnv("USER");
        #end
    }

    /**
    Handles user input and passes it to the interpreter
    **/
    private function processInput()
    {
        print(getUserName(), Green);
        print(':${Dir.getCWD().path.filename}$ ', Blue);
        var submit = false;
        var buf = new StringBuilder();
        while (!submit)
        {
            var char = Sys.getChar(false);
            var input = String.fromCharCode(char);
            //print(Std.string(char), White);
            switch (char)
            {
                case 3: //Ctrl + C
                wantsToQuit = true;
                break;
                case 13: //newline
                submit = true;
                case 9: //Tab
                buf.add("TAB");
                case 127: //Delete
                var bufTemp = buf.toString();
                buf.clear(); //Nasty evil hack to remove the last char from the StringBuilder since Haxe inexplicably doesn't have a remove() in StringBuf
                buf.add(bufTemp.substr(0, bufTemp.length - 2));
                print(String.fromCharCode(127), White); //Backspaces the last char typed in
                default:
                 buf.add(input);
                 print(input, White);
            }
        }
        println("", White);
        println(buf.toString(), Cyan);
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
    Escapes the given string with terminal colour codes
    @param str The string to wrap in the colour code
    @param color The ANSIColor to use
    **/
    static function colorEscape(str: String, color: ANSIColor)
    {
        return switch (color) 
        {
            case Rgb(r, g, b): '\u001b[38;2;${r};${g};${b}m${str}\u001b[39;49m';
            default: '\u001b[38;5;${Type.enumIndex(color)}m${str}\u001b[39;49m';
        }
    }

    /**
    Prints text to the terminal, with an appended newline.
    @param msg The message to print
    @param color Optional ANSI colour
    **/
    public function println(msg: String, ?color: ANSIColor)
    {
        if (color == null) Sys.println(msg);
        else Sys.println(colorEscape(msg, color));
    }

    /**
    Prints text to the terminal.
    @param msg The message to print
    @param color Optional ANSI colour
    **/
    public function print(msg: String, ?color: ANSIColor)
    {
        if (color == null) Sys.print(msg);
        Sys.print(colorEscape(msg, color));
    }
}
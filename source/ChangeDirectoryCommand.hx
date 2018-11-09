using haxe.io.Path;
using sys.FileSystem;

class ChangeDirectoryCommand implements BuiltinCommand
{
    public function new() {}

    @:keep
    public function exec(args: Array<String>)
    {
        if (args.length > 0)
        {
            var absPath = FileSystem.absolutePath(args[0]);
            if (FileSystem.exists(absPath))
            {
                Sys.setCwd(absPath);
            }
            else
            {
                ShellEnvironment.instance.println('cd: directory ${absPath} does not exist.');
            }
        }
        else
        {
            ShellEnvironment.instance.println(Sys.getCwd());
        }
    }
}
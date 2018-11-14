using hx.files.Path;
using hx.files.Dir;

class ChangeDirectoryCommand implements BuiltinCommand
{
    public function new() {}

    @:keep
    public function exec(args: Array<String>)
    {
        if (args.length > 0)
        {
            var path = Dir.getCWD().path.join(args[0]);
            path.normalize();            
            if (path.exists())
            {
                var dir = Dir.of(path);
                dir.setCWD();
            }
            else
            {
                ShellEnvironment.instance.println('cd: directory ${path.getAbsolutePath()} does not exist.');
            }
        }
        else
        {
            ShellEnvironment.instance.println(Std.string(Dir.getCWD()));
        }
    }
}
use v6;

class Test::Redis {
    has $.port = 16379;
    has $.stdout = '';
    has $.stderr = '';
    has $.proc;
    has $.done;

    method start() returns Bool {
        try {
            $!proc = Proc::Async.new('redis-server', '-', :w, :r);

            $!proc.stdout.tap(-> $buf { $!stdout ~= $buf });
            $!proc.stderr.tap(-> $buf { $!stderr ~= $buf });

            $!done = $!proc.start;

            await $!proc.print(qq:to/END/);
                port $!port
                bind 127.0.0.1
                logfile ""
                END

            $!proc.close-stdin;
 
            CATCH { default { return False } }
        }
        return True;
    }

    method finish() {
        $!proc.kill('INT') unless $!done;
        try sink await $!done;
        return True;
    }
}


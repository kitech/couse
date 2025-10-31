module mpvut

pub struct Cmdargs {
    pub mut:
    args []string
}

pub fn Cmdargs.new() &Cmdargs {
    o := &Cmdargs{}
    return o
}

pub fn (o &Cmdargs) toline() string {
    return o.args.join(" ")
}

pub fn (o &Cmdargs) toarray()  [] string {
    return o.args
}

pub fn (o &Cmdargs) tomap()  map[string]string {
    return map[string]string{}
}

// xv/gl/ngl
pub fn (o &Cmdargs) vo(name string) &Cmdargs{
    o.args << "-vo=${name}"
    return o
}

pub fn (o &Cmdargs) input(file string) &Cmdargs{
    o.args << "--input=${file}"
    return o
}

pub fn (o &Cmdargs) config(on bool) &Cmdargs {
    if !on {
        o.args << "--no-config"
    }
    return o
}

pub fn (o &Cmdargs) terminal(on bool) &Cmdargs{
    if !on {
        o.args << "--no-terminal"
    }
    return o
}

pub fn (o &Cmdargs) keep_open(on bool) &Cmdargs{
    o.args << "--keep-open=" + (if on {"yes"} else {"no"})
    return o
}

pub fn (o &Cmdargs) osc(on bool) &Cmdargs{
    o.args << "--osc=" + (if on {"yes"} else {"no"})
    return o
}

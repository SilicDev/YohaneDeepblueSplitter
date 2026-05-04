state("game")
{
    short finish: 0x166B418, 0x51058;
    short start: 0x166B418, 0x51071;
    long questflags: 0x166B418, 0x51074;
    short bossflags: 0x166B418, 0x5107D;
    short area: 0x166B418, 0x585EC;
    byte control: 0x0115B498, 0x28, 0x8, 0x8, 0xD0;
    long framecounter: 0x0115B498, 0x28, 0x8, 0x8, 0x238;
}

init
{
    refreshRate = 120;
}

startup
{
    vars.starttime = 0;
	settings.Add("area_change", false, "Split on Area change");
	settings.Add("upgrade_received", false, "Split on returning upgrade items.");
}

start
{
    if (current.start == 6 && current.control == 2 && old.control != 2)
    {
        vars.starttime = current.framecounter;
        return true;
    }
    return false;
}

update
{
    
}

split
{
    if (settings["area_change"])
    {
        if (current.area != old.area && current.area != 0 && old.area != 0 )
        {
            return true;
        }
    }
    if (settings["upgrade_received"])
    {
        if ((current.questflags & 0x492492) != (old.questflags & 0x492492))
        {
            return true;
        }
    }
    if ((current.bossflags & 0xFFE0) != (old.bossflags & 0xFFE0))
    {
        return true;
    }
    if (current.finish & 0x1 != 0 && current.finish != old.finish)
    {
        return true;
    }
    return false;
}

reset
{
    return current.framecounter < old.framecounter;
}

gameTime
{
    return TimeSpan.FromMilliseconds((current.framecounter - vars.starttime) * (1/120.0 * 1000));
}

isLoading
{
    return old.framecounter == current.framecounter;
}

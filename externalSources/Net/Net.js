function JSGetAsync(url, args, success, err){
    console.log("net");
    $.get(url, {})
    .done(success)
    .fail(err);
}
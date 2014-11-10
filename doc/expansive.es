Expansive.load({
    meta: {
        title:       'Appweb Documentation',
        url:         'https://embedthis.com/appweb/doc',
        keywords:    'appweb, embedded web server, embedded, devices, http server, internet of things, esp, goahead',
    },
    expansive: {
        copy: [ 'images' ],
        dependencies: { 'css/all.css.less': 'css/*.inc.less' },
        documents: [ '**', '!css/*.inc.less' ],
        plugins: [ 'less' ],
    }
})

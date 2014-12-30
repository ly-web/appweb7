Expansive.load({
    meta: {
        title: 'Appweb Documentation',
        url:   'https://embedthis.com/appweb/doc',
    },
    control: {
        copy: [ 'images' ],
        dependencies: { 'css/all.css.less': '**.less' },
        documents: [ '**', '!**.less', '**.css.less' ],
        plugins: [ 'less' ],
    }
})

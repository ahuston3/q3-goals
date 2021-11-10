module.exports = {
    publicPath: process.env.NODE_ENV === 'production'
        ? '/q3-goals/'
        : '/'
    ,
    configureWebpack: {        
        devServer: {
            headers: {
                'Access-Control-Allow-Origin': '*'            
            }
        }
    },
};
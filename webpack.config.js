module.exports = {
  entry: "./index.js",
  mode: "development",

  output: {
    path: __dirname + "/dist",
    filename: "index.js"
  },

  resolve: { extensions: [".elm", ".js", ".scss", ".css"] },
  module: {
    rules: [
      {
        test: /\.html$/,
        exclude: /node_modules/,
        use: {
          loader: "file-loader",
          options: {
            name: "[name].[ext]"
          }
        }
      },
      {
        test: /\.elm$/,
        exclude: [/elm-stuff/, /node_modules/],
        use: {
          loader: "elm-webpack-loader?verbose=true&warn=true",
          options: {}
        }
      },
      {
        test: /\.scss$/,
        use: [
          "style-loader", // creates style nodes from JS strings
          "css-loader", // translates CSS into CommonJS
          "sass-loader" // compiles Sass to CSS, using Node Sass by default
        ]
      },
      {
        test: /\.css$/,
        use: [
          "style-loader", // creates style nodes from JS strings
          "css-loader" // translates CSS into CommonJS
        ]
      }
    ],
    noParse: /\.elm$/
  },

  devServer: {
    inline: true,
    stats: "errors-only"
  }
};

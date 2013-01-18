// Generated by CoffeeScript 1.3.3
(function() {
  var BasePlot,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  BasePlot = (function() {

    function BasePlot() {
      this.draw = __bind(this.draw, this);
      this._width = 720;
      this._height = 680;
    }

    BasePlot.prototype.draw = function(selection) {
      var me;
      me = this;
      return selection.each(function(d, i) {
        return me._draw(this, d, i);
      });
    };

    BasePlot.prototype._draw = function(elem, data, i) {
      throw "Not implemented";
    };

    BasePlot.prototype.width = function(value) {
      if (!arguments.length) {
        return this._width;
      }
      this._width = value;
      return this;
    };

    BasePlot.prototype.height = function(value) {
      if (!arguments.length) {
        return this._height;
      }
      this._height = value;
      return this;
    };

    BasePlot.prototype.configure_viewport = function(elem, x_domain, y_domain, xtime) {
      var container, margins, plot, plot_dims, svg, svg_dims, x, xaxis, y, yaxis;
      if (xtime == null) {
        xtime = false;
      }
      container = d3.select(elem);
      margins = {
        top: 10,
        right: 20,
        bottom: 30,
        left: 60
      };
      svg_dims = {
        width: this.width(),
        height: this.height()
      };
      plot_dims = {
        width: svg_dims.width - margins.left - margins.right,
        height: svg_dims.height - margins.top - margins.bottom
      };
      svg = container.append('svg').attr('width', svg_dims.width).attr('height', svg_dims.height);
      plot = svg.append('g').attr('transform', "translate(" + margins.left + ", " + margins.top + ")");
      if (xtime) {
        x = d3.time.scale().domain(x_domain).range([0, plot_dims.width]);
      } else {
        x = d3.scale.linear().domain(x_domain).range([0, plot_dims.width]);
      }
      y = d3.scale.linear().domain(y_domain).range([plot_dims.height, 0]);
      xaxis = d3.svg.axis().scale(x);
      yaxis = d3.svg.axis().scale(y).orient('left');
      plot.append('g').attr('class', 'x axis').attr('transform', "translate(0, " + plot_dims.height + ")").call(xaxis);
      plot.append('g').attr('class', 'y axis').call(yaxis);
      return {
        plot: plot,
        x: x,
        y: y
      };
    };

    return BasePlot;

  })();

  window.Plot = (function(_super) {

    __extends(Plot, _super);

    function Plot() {
      this.hide_tooltip = __bind(this.hide_tooltip, this);

      this.show_tooltip = __bind(this.show_tooltip, this);
      Plot.__super__.constructor.call(this);
      this.tooltip = d3.select("body").append("div").style("display", "none").style("background-color", "#eee").style("background-color", "rgba(242, 242, 242, .6)").style("padding", "5px").style("position", "absolute");
    }

    Plot.prototype._draw = function(elem, data) {
      var author_counts, color, d, line, plot, points, x, x_domain, y, y_domain, _i, _len, _ref,
        _this = this;
      for (_i = 0, _len = data.length; _i < _len; _i++) {
        d = data[_i];
        data.timestamp = new Date(data.timestamp);
      }
      x_domain = d3.extent(data, function(d) {
        return d.timestamp;
      });
      y_domain = d3.extent(data, function(d) {
        return d.comments;
      });
      author_counts = d3.nest().key(function(story) {
        return story.author;
      }).rollup(function(group) {
        return group.length;
      }).map(data);
      color = d3.scale.category10().domain(d3.keys(author_counts).sort());
      _ref = this.configure_viewport(elem, x_domain, y_domain, true), plot = _ref.plot, x = _ref.x, y = _ref.y;
      points = plot.selectAll('circle').data(data);
      points.enter().append('circle').attr('cx', function(d) {
        return x(d.timestamp);
      }).attr('cy', function(d) {
        return y(d.comments);
      }).attr('r', 5).attr('fill', function(d) {
        return color(d.author);
      });
      line = d3.svg.line().x(function(d) {
        return x(d.timestamp);
      }).y(function(d) {
        return y(d.comments);
      });
      plot.append('path').attr('d', line(data)).style('stroke', 'blue').style('fill', 'none');
      return plot.selectAll('circle').on('mouseover', function(d) {
        return _this.show_tooltip("" + d.title + "<br>" + d.author);
      }).on('mouseout', function(d) {
        return _this.hide_tooltip();
      });
    };

    Plot.prototype.show_tooltip = function(html) {
      var m;
      m = d3.mouse(d3.select("body").node());
      return this.tooltip.style("display", null).style("left", m[0] + 30 + "px").style("top", m[1] - 20 + "px").html(html);
    };

    Plot.prototype.hide_tooltip = function() {
      return this.tooltip.style("display", "none");
    };

    return Plot;

  })(BasePlot);

}).call(this);

(window.webpackJsonp=window.webpackJsonp||[]).push([[12],{2177:function(n,e,t){"use strict";t.r(e),t.d(e,"autoLayout",(function(){return u}));var o=t(0),c=t.n(o),i=t(2176),a=new(t.n(i).a);function u(n){n.hasChanges=!0;var e={id:"",layoutOptions:{"elk.algorithm":"layered","crossingMinimization.semiInteractive":!0,"nodePlacement.strategy":"NETWORK_SIMPLEX"},children:[],edges:[]};e.children=Object.values(n.nodes).map((function(n){var e=Object.keys(n.inputTerminals).map((function(e,t){return{id:"".concat(n._uid,"/in/").concat(e),properties:{"port.side":"WEST","port.index":t}}})),t=Object.keys(n.outputTerminals).map((function(e,t){return{id:"".concat(n._uid,"/out/").concat(e),properties:{"port.side":"EAST","port.index":t}}}));return{id:n._uid,height:c()(n.element).height()+20,width:c()(n.element).width()+60,ports:e.concat(t)}})),Object.values(n.nodes).forEach((function(n){Object.values(n.inputTerminals).forEach((function(t){t.connectors.forEach((function(t){e.edges.push({id:"e_".concat(n._uid,"_").concat(t.outputHandle.node._uid),sources:["".concat(t.outputHandle.node._uid,"/out/").concat(t.outputHandle.name)],targets:["".concat(t.inputHandle.node._uid,"/in/").concat(t.inputHandle.name)]})}))}))})),a.layout(e).then((function(e){e.children.forEach((function(e){var t=Object.values(n.nodes).filter((function(n){return n._uid===e.id}))[0],o=c()(t.element);c()(o).css({top:e.y,left:e.x})})),Object.values(n.nodes).forEach((function(n){n.onRedraw()}))})).catch(console.error)}}}]);
//# sourceMappingURL=workflowLayout.chunk.js.map
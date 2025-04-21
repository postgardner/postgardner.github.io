import{p as V}from"./chunk-4BMEZGHF.Dd8hVLyl.js";import{P as y,S as z,aE as U,_ as p,g as j,s as q,a as Z,b as H,q as J,p as K,l as G,c as Q,E as X,I as Y,a3 as tt,d as et,y as at,G as rt}from"./mermaid.core.C3bmJkXv.js";import{p as nt}from"./radar-MK3ICKWK.BzkhXf0H.js";import"./transform.7sWRJG2v.js";import{d as N}from"./arc.vOJFiKu1.js";import{o as it}from"./ordinal.BYWQX77i.js";import"./preload-helper.BlTxHScW.js";import"./_commonjsHelpers.Cpj98o6Y.js";import"./_baseUniq.C2ZE5Tqn.js";import"./_basePickBy.D2biO7dX.js";import"./clone.BZpoEXxc.js";import"./init.Gi6I4Gst.js";function st(t,a){return a<t?-1:a>t?1:a>=t?0:NaN}function ot(t){return t}function lt(){var t=ot,a=st,m=null,s=y(0),u=y(z),x=y(0);function i(e){var r,l=(e=U(e)).length,d,A,h=0,c=new Array(l),n=new Array(l),v=+s.apply(this,arguments),w=Math.min(z,Math.max(-z,u.apply(this,arguments)-v)),f,T=Math.min(Math.abs(w)/l,x.apply(this,arguments)),$=T*(w<0?-1:1),g;for(r=0;r<l;++r)(g=n[c[r]=r]=+t(e[r],r,e))>0&&(h+=g);for(a!=null?c.sort(function(S,C){return a(n[S],n[C])}):m!=null&&c.sort(function(S,C){return m(e[S],e[C])}),r=0,A=h?(w-l*$)/h:0;r<l;++r,v=f)d=c[r],g=n[d],f=v+(g>0?g*A:0)+$,n[d]={data:e[d],index:r,value:g,startAngle:v,endAngle:f,padAngle:T};return n}return i.value=function(e){return arguments.length?(t=typeof e=="function"?e:y(+e),i):t},i.sortValues=function(e){return arguments.length?(a=e,m=null,i):a},i.sort=function(e){return arguments.length?(m=e,a=null,i):m},i.startAngle=function(e){return arguments.length?(s=typeof e=="function"?e:y(+e),i):s},i.endAngle=function(e){return arguments.length?(u=typeof e=="function"?e:y(+e),i):u},i.padAngle=function(e){return arguments.length?(x=typeof e=="function"?e:y(+e),i):x},i}var ct=rt.pie,F={sections:new Map,showData:!1},b=F.sections,P=F.showData,pt=structuredClone(ct),ut=p(()=>structuredClone(pt),"getConfig"),dt=p(()=>{b=new Map,P=F.showData,at()},"clear"),gt=p(({label:t,value:a})=>{b.has(t)||(b.set(t,a),G.debug(`added new section: ${t}, with value: ${a}`))},"addSection"),ft=p(()=>b,"getSections"),mt=p(t=>{P=t},"setShowData"),ht=p(()=>P,"getShowData"),O={getConfig:ut,clear:dt,setDiagramTitle:K,getDiagramTitle:J,setAccTitle:H,getAccTitle:Z,setAccDescription:q,getAccDescription:j,addSection:gt,getSections:ft,setShowData:mt,getShowData:ht},vt=p((t,a)=>{V(t,a),a.setShowData(t.showData),t.sections.map(a.addSection)},"populateDb"),St={parse:p(async t=>{const a=await nt("pie",t);G.debug(a),vt(a,O)},"parse")},yt=p(t=>`
  .pieCircle{
    stroke: ${t.pieStrokeColor};
    stroke-width : ${t.pieStrokeWidth};
    opacity : ${t.pieOpacity};
  }
  .pieOuterCircle{
    stroke: ${t.pieOuterStrokeColor};
    stroke-width: ${t.pieOuterStrokeWidth};
    fill: none;
  }
  .pieTitleText {
    text-anchor: middle;
    font-size: ${t.pieTitleTextSize};
    fill: ${t.pieTitleTextColor};
    font-family: ${t.fontFamily};
  }
  .slice {
    font-family: ${t.fontFamily};
    fill: ${t.pieSectionTextColor};
    font-size:${t.pieSectionTextSize};
    // fill: white;
  }
  .legend text {
    fill: ${t.pieLegendTextColor};
    font-family: ${t.fontFamily};
    font-size: ${t.pieLegendTextSize};
  }
`,"getStyles"),xt=yt,At=p(t=>{const a=[...t.entries()].map(s=>({label:s[0],value:s[1]})).sort((s,u)=>u.value-s.value);return lt().value(s=>s.value)(a)},"createPieArcs"),wt=p((t,a,m,s)=>{G.debug(`rendering pie chart
`+t);const u=s.db,x=Q(),i=X(u.getConfig(),x.pie),e=40,r=18,l=4,d=450,A=d,h=Y(a),c=h.append("g");c.attr("transform","translate("+A/2+","+d/2+")");const{themeVariables:n}=x;let[v]=tt(n.pieOuterStrokeWidth);v??=2;const w=i.textPosition,f=Math.min(A,d)/2-e,T=N().innerRadius(0).outerRadius(f),$=N().innerRadius(f*w).outerRadius(f*w);c.append("circle").attr("cx",0).attr("cy",0).attr("r",f+v/2).attr("class","pieOuterCircle");const g=u.getSections(),S=At(g),C=[n.pie1,n.pie2,n.pie3,n.pie4,n.pie5,n.pie6,n.pie7,n.pie8,n.pie9,n.pie10,n.pie11,n.pie12],D=it(C);c.selectAll("mySlices").data(S).enter().append("path").attr("d",T).attr("fill",o=>D(o.data.label)).attr("class","pieCircle");let W=0;g.forEach(o=>{W+=o}),c.selectAll("mySlices").data(S).enter().append("text").text(o=>(o.data.value/W*100).toFixed(0)+"%").attr("transform",o=>"translate("+$.centroid(o)+")").style("text-anchor","middle").attr("class","slice"),c.append("text").text(u.getDiagramTitle()).attr("x",0).attr("y",-400/2).attr("class","pieTitleText");const M=c.selectAll(".legend").data(D.domain()).enter().append("g").attr("class","legend").attr("transform",(o,E)=>{const k=r+l,L=k*D.domain().length/2,_=12*r,B=E*k-L;return"translate("+_+","+B+")"});M.append("rect").attr("width",r).attr("height",r).style("fill",D).style("stroke",D),M.data(S).append("text").attr("x",r+l).attr("y",r-l).text(o=>{const{label:E,value:k}=o.data;return u.getShowData()?`${E} [${k}]`:E});const R=Math.max(...M.selectAll("text").nodes().map(o=>o?.getBoundingClientRect().width??0)),I=A+e+r+l+R;h.attr("viewBox",`0 0 ${I} ${d}`),et(h,d,I,i.useMaxWidth)},"draw"),Ct={draw:wt},It={parser:St,db:O,renderer:Ct,styles:xt};export{It as diagram};

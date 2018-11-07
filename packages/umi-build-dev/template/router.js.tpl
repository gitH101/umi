{{{ importsAhead }}}
import React from 'react';
import { Router as DefaultRouter, Route, Switch } from 'react-router-dom';
import dynamic from 'umi/dynamic';
import renderRoutes from 'umi/_renderRoutes';
{{{ imports }}}

let Router = {{{ RouterRootComponent }}};

let routes = {{{ routes }}};

const transRoute = (menus) =>{
  return menus.map(item=>{
    const result = {...item};
    if(!!item.routes && item.routes.length > 0){
      result.routes = transRoute(item.routes);
    }else {
      result.exact = true;
    }
    return result;
  })
}

@connect(({ route, loading }) => ({
  menus: route.menus
}),(dispatch)=>({
  queryMenus: payload=>dispatch({type:'route/queryMenus',payload})
}))
export default class Route extends PureComponent {

  constructor(props){
    super(props);
  }

  componentWillMount(){
    const {queryMenus} = this.props;
    queryMenus();
  }

  transRoutes(){
    const {menus} = this.props;
    return transRoute(menus);
  }
  render(){
    const routes = this.transRoute();
    window.g_plugins.applyForEach('patchRoutes', { initialValue: routes });
      return (
    {{{ routerContent }}}
      );
   }
}

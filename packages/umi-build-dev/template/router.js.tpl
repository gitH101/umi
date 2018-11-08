{{{ importsAhead }}}
import React, { PureComponent } from 'react';
import { Router as DefaultRouter, Route, Switch } from 'react-router-dom';
import { connect } from 'dva';
import update from 'react-addons-update';
import { createSelector } from 'reselect';
import dynamic from 'umi/dynamic';
import renderRoutes from 'umi/_renderRoutes';
{{{ imports }}}

let Router = {{{ RouterRootComponent }}};

let routes = {{{ routes }}};

const transMenuMap = createSelector(
  [ route=>route && route.menus || [] ],
  (menus) => menus.reduce((result,menu)=>result[menu.key] = true,{})
);
const transRoute = (routes, menuMap) =>{
  let tem = [];
  routes.forEach(route=>{
    const routeNew = {...route};
    if(!!route.routes && route.routes.length > 0){
      routeNew.routes = transRoute(route.routes, menuMap)
    }
    if((!!routeNew.routes && routeNew.routes.length > 0) || (!!route.name && menuMap[route.name])){
      tem.push(routeNew);
    }
  });
  return tem;
};

@connect(({ route, login }) => ({
  menuMap: transMenuMap(route),
  loginStatus: login.status
}),(dispatch)=>({
  queryMenus: payload=>dispatch({type:'route/queryMenus',payload})
}))
export default class RouteEd extends PureComponent {
  constructor(props){
    super(props);
    this.state = {tag:true}
  }

  componentWillMount(){
    const {queryMenus} = this.props;
    queryMenus();
  }

  componentWillReceiveProps(next){
    this.setState({tag:false});
    const { loginStatus, queryMenus } = this.props;
    if(next.loginStatus !== loginStatus){
      queryMenus();
    }
  }

  transRoutes(){
    const {menuMap} = this.props;
    const {tag} = this.state;
    if(tag){
      return routes;
    }
	const pathRoutes = transRoute(routes[1].routes, menuMap);
	const newRoutes = [...routes];
	const newRoute1 = {...newRoutes[1]}
	newRoute1.routes = pathRoutes;
	newRoutes[1] = newRoute1;
    return newRoutes;
  }
  render(){
    const routes = this.transRoutes();
    window.g_plugins.applyForEach('patchRoutes', { initialValue: routes });
      return (
    {{{ routerContent }}}
      );
   }
}

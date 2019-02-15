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
  (menus) => menus.reduce((result,menu)=>{
	result[menu.key] = true;
	return result;
  },{})
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
  menus: route && route.menus || [],
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
    const { loginStatus, queryMenus } = this.props;
    if(next.loginStatus !== loginStatus){
      queryMenus();
    }
  }

  transRoutes(){
    const {menuMap, menus} = this.props;
    if(menus && menus.length > 0){
		console.log(transRoute(routes[1].routes, menuMap), menus);
        return update(routes,{[1]:{routes:{$set:transRoute(routes[1].routes, menuMap)}}});
    }
	return routes;
  }
  render(){
    const routes = this.transRoutes();

      return (
    {{{ routerContent }}}
      );
   }
}

import r from 'r-dom';
import { Provider } from 'react-redux';
import middleware from 'redux-thunk';
import { combineReducers, applyMiddleware, createStore } from 'redux';
import { initialize as initializeI18n } from '../utils/i18n';
import reducers from '../reducers/reducersIndex';

import OnlineStore from '../components/sections/OnlineStore/OnlineStore';

export default (props) => {
  const combinedReducer = combineReducers(reducers);
  const initialStoreState = {
    onlineStore: props
  };
  const store = applyMiddleware(middleware)(createStore)(combinedReducer, initialStoreState);

  const containerProps = props;

  return r(Provider, { store }, [
    r(OnlineStore, containerProps),
  ]);
}
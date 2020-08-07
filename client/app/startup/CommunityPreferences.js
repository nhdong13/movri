import r from 'r-dom';
import { Provider } from 'react-redux';
import middleware from 'redux-thunk';
import { combineReducers, applyMiddleware, createStore } from 'redux';
import { initialize as initializeI18n } from '../utils/i18n';
import reducers from '../reducers/reducersIndex';

import CommunityPreferences from '../components/composites/CommunityPreferences/CommunityPreferences';

export default (props) => {
  const combinedReducer = combineReducers(reducers);
  const initialPreferencesState = {
    preferences: props
  };
  const store = applyMiddleware(middleware)(createStore)(combinedReducer, initialPreferencesState);

  const containerProps = props;

  return r(Provider, { store }, [
    r(CommunityPreferences, containerProps),
  ]);
}
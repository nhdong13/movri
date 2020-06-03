import Immutable from 'immutable';
import r from 'r-dom';
import { Provider } from 'react-redux';
import middleware from 'redux-thunk';
import { combineReducers, applyMiddleware, createStore } from 'redux';
import reducers from '../reducers/reducersIndex';
import { initialize as initializeI18n } from '../utils/i18n';
import CartPage from '../components/sections/CartPage/CartPage';

export default (props) => {
  const combinedReducer = combineReducers(reducers);
  const initialStoreState = {
    changeQuantity: Immutable.List(),
    listingcart: props.listing
  };
  const store = applyMiddleware(middleware)(createStore)(combinedReducer, initialStoreState);

  const containerProps = {
    header: {
      imageUrl: "/aaa/aaa/aa",
      title: props.listing.title,
    }
  };

  return r(Provider, { store }, [
    r(CartPage, containerProps),
  ]);
}
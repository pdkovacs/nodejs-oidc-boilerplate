import { createAppSlice } from "../../app/createAppSlice";
import type { UserInfo } from "../../dto/UserInfo";
import { fetchUserInfo } from "./userApi";

export interface UserSliceState {
  status: "initial" | "loading" | "authenticated",
	userInfo: UserInfo | null
}

const initialState: UserSliceState = {
  status: "initial",
	userInfo: null
};

export const userSlice = createAppSlice({
  name: "user",
  initialState,
  reducers: create => ({
		getUserInfo: create.asyncThunk(
      async () => {
        const response = await fetchUserInfo();
        return response.userInfo;
      },
      {
        pending: state => {
          state.status = "loading";
        },
        fulfilled: (state, action) => {
          state.status = "authenticated";
          state.userInfo = action.payload;
        },
        rejected: state => {
          state.status = "initial";
        },
      }
		),
		setAuthenticated: create.reducer(state => {
			state.status = "authenticated";
		})
  }),
  selectors: {
    selectStatus: user => user.status,
		selectUserInfo: user => user.userInfo
  },
});

export const { getUserInfo, setAuthenticated } =
  userSlice.actions;

export const { selectStatus, selectUserInfo } = userSlice.selectors;

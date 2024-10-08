import { IconButton, Link, Menu, MenuItem } from "@mui/material";
import AccountCircleIcon from '@mui/icons-material/AccountCircle';
import "./App.css";
import { useAppDispatch, useAppSelector } from "./app/hooks";
import { getUserInfo, selectStatus, selectUserInfo } from "./features/user/userSlice";
import { useEffect, useRef, useState } from "react";
import { AuthzTests } from "./features/authzTests/AuthzTests";
import { isNil } from "lodash-es";
import axios from "axios";

const App = () => {
	const userStatus = useAppSelector(selectStatus);

	const userIsLoggedIn = userStatus === "authenticated";

	const dispatch = useAppDispatch();

	useEffect(() => {
		dispatch(getUserInfo());
	}, [dispatch]);

  return (
    <div className="App">
			{ userIsLoggedIn && <AppHeader /> }
      <div className="App-body">
				{
					userIsLoggedIn
						? <AuthzTests/>
						: <Link href="/login">Login</Link>
				}
 			</div>
    </div>
  );
};

const AppHeader = () => {

	const userMenuAnchor = useRef<HTMLButtonElement>(null);
	const [userMenuIsOpen, setUserMenuIsOpen] = useState(false);

	const userInfo = useAppSelector(selectUserInfo);

	return <header className="App-header">
		<div>
			{userInfo?.username}
			<IconButton
				ref={userMenuAnchor}
				onClick={() => {
					setUserMenuIsOpen(!userMenuIsOpen);
				}}
			>
					<AccountCircleIcon/>
			</IconButton>
		</div>
		<UserMenu open={userMenuIsOpen} anchorEl={userMenuAnchor.current} />
	</header>;
};

interface UserMenuProps {
	readonly open: boolean;
	readonly anchorEl: HTMLElement | null;
}

const UserMenu = ({ open, anchorEl }: UserMenuProps) => {
	return <Menu
		id="basic-menu"
		anchorEl={anchorEl}
		open={open && !isNil(anchorEl)}
		onClose={() => undefined}
		MenuListProps={{
			'aria-labelledby': 'basic-button',
		}}
	>
		<MenuItem onClick={async () => {
			const response = await axios.post("/api/logout");
			if (response.data?.logoutUrl) {
				window.location.href = response.data?.logoutUrl;
			}
		}}>Logout</MenuItem>
	</Menu>;
};

export default App;

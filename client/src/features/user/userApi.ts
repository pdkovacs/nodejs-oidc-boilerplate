import axios from "axios";
import type { UserInfo } from "../../dto/UserInfo";

export const fetchUserInfo = async (): Promise<{userInfo: UserInfo}> => {
	const axiosResponse = await axios({
		method: "GET",
		url: "/api/user" 
	});
	return {...axiosResponse.data};
};

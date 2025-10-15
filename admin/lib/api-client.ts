import axios, { AxiosRequestConfig, AxiosResponse } from "axios";
import { getSession } from "next-auth/react";
import { GetServerSidePropsContext } from "next";

// Custom hook for making authenticated API calls to Azure Function App
export function useApiClient() {
  const getAccessToken = async (
    context?: GetServerSidePropsContext
  ): Promise<string> => {
    try {
      // Lấy session từ NextAuth
      const session = context ? await getSession(context) : await getSession();
      if (!session || !session.user.accessToken) {
        throw new Error("No authenticated session or access token found");
      }
      return session.user.accessToken;
    } catch (error) {
      console.error("Failed to acquire access token:", error);
      throw new Error("Failed to acquire access token");
    }
  };

  const apiCall = async (
    endpoint: string,
    config: AxiosRequestConfig = {},
    context?: GetServerSidePropsContext
  ): Promise<AxiosResponse> => {
    try {
      const accessToken = await getAccessToken(context);

      const headers = {
        Authorization: `Bearer ${accessToken}`,
        "Content-Type": "application/json",
        ...config.headers,
      };

      const response = await axios({
        url: endpoint,
        ...config,
        headers,
      });

      return response;
    } catch (error) {
      console.error("API call failed:", error);
      throw error;
    }
  };

  const get = async (
    endpoint: string,
    context?: GetServerSidePropsContext
  ): Promise<any> => {
    const response = await apiCall(endpoint, { method: "GET" }, context);
    return response.data;
  };

  const post = async (
    endpoint: string,
    data: any,
    context?: GetServerSidePropsContext
  ): Promise<any> => {
    const response = await apiCall(endpoint, { method: "POST", data }, context);
    return response.data;
  };

  const put = async (
    endpoint: string,
    data: any,
    context?: GetServerSidePropsContext
  ): Promise<any> => {
    const response = await apiCall(endpoint, { method: "PUT", data }, context);
    return response.data;
  };

  const del = async (
    endpoint: string,
    context?: GetServerSidePropsContext
  ): Promise<any> => {
    const response = await apiCall(endpoint, { method: "DELETE" }, context);
    return response.data;
  };

  return {
    getAccessToken,
    apiCall,
    get,
    post,
    put,
    delete: del,
  };
}

// Utility class for non-hook usage
export class ApiClient {
  private context?: GetServerSidePropsContext;

  constructor(context?: GetServerSidePropsContext) {
    this.context = context;
  }

  async getAccessToken(): Promise<string> {
    try {
      // Lấy session từ NextAuth
      const session = this.context
        ? await getSession(this.context)
        : await getSession();
      if (!session || !session.user.accessToken) {
        throw new Error("No authenticated session or access token found");
      }
      return session.user.accessToken;
    } catch (error) {
      console.error("Failed to acquire access token:", error);
      throw new Error("Failed to acquire access token");
    }
  }

  async apiCall(
    endpoint: string,
    config: AxiosRequestConfig = {}
  ): Promise<AxiosResponse> {
    try {
      const accessToken = await this.getAccessToken();

      const headers = {
        Authorization: `Bearer ${accessToken}`,
        "Content-Type": "application/json",
        ...config.headers,
      };

      const response = await axios({
        url: endpoint,
        ...config,
        headers,
      });

      return response;
    } catch (error) {
      console.error("API call failed:", error);
      throw error;
    }
  }

  async get(endpoint: string): Promise<any> {
    const response = await this.apiCall(endpoint, { method: "GET" });
    return response.data;
  }

  async post(endpoint: string, data: any): Promise<any> {
    const response = await this.apiCall(endpoint, { method: "POST", data });
    return response.data;
  }

  async put(endpoint: string, data: any): Promise<any> {
    const response = await this.apiCall(endpoint, { method: "PUT", data });
    return response.data;
  }

  async delete(endpoint: string): Promise<any> {
    const response = await this.apiCall(endpoint, { method: "DELETE" });
    return response.data;
  }
}

"use client";

import { useState, useEffect } from "react";
import { useSession, signOut } from "next-auth/react";
import { useApiClient } from "@/lib/api-client";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar";
import {
  BarChart3,
  Home,
  Users,
  Settings,
  LogOut,
  Menu,
  X,
  Activity,
  TrendingUp,
  DollarSign,
  Clock,
} from "lucide-react";
import { cn } from "@/lib/utils";

interface DashboardLayoutProps {
  children: React.ReactNode;
}

export function DashboardLayout({ children }: DashboardLayoutProps) {
  const { data: session } = useSession();
  const [sidebarOpen, setSidebarOpen] = useState(false);
  const [functionData, setFunctionData] = useState<any>(null);
  const [loading, setLoading] = useState(false);
  const apiClient = useApiClient();

  const user = session?.user;
  useEffect(() => {
    const logToken = async () => {
      const token = await apiClient.getAccessToken();
      console.log("Access Token:", token);

      console.log("User Info:", user);
    };

    logToken();
  }, [apiClient.getAccessToken]);

  const handleLogout = () => {
    signOut({ callbackUrl: "/auth/signin" });
  };

  const navigation = [
    { name: "Dashboard", href: "#", icon: Home, current: true },
    { name: "Analytics", href: "#", icon: BarChart3, current: false },
    { name: "Users", href: "#", icon: Users, current: false },
    { name: "Settings", href: "#", icon: Settings, current: false },
  ];

  const stats = [
    {
      name: "Total Revenue",
      value: "$45,231.89",
      change: "+20.1%",
      icon: DollarSign,
      trend: "up",
    },
    {
      name: "Active Users",
      value: "2,350",
      change: "+180.1%",
      icon: Users,
      trend: "up",
    },
    {
      name: "Sales",
      value: "12,234",
      change: "+19%",
      icon: TrendingUp,
      trend: "up",
    },
    {
      name: "Active Now",
      value: "573",
      change: "+201",
      icon: Activity,
      trend: "up",
    },
  ];

  // Example function to call your Azure Function App
  const callFunctionApp = async () => {
    setLoading(true);
    try {
      // Replace with your actual Function App endpoint
      const endpoint = `https://your-function-app.azurewebsites.net/api/your-function-name`;
      const data = await apiClient.get(endpoint);
      setFunctionData(data);
      console.log("Function App Response:", data);
    } catch (error) {
      console.error("Failed to call Function App:", error);
    } finally {
      setLoading(false);
    }
  };

  // Example of calling Function App on component mount
  useEffect(() => {
    if (user) {
      // Uncomment to automatically call your Function App on load
      // callFunctionApp();
    }
  }, [user]);

  return (
    <div className="flex h-screen bg-gray-100">
      {/* Mobile sidebar overlay */}
      {sidebarOpen && (
        <div className="fixed inset-0 flex z-40 md:hidden">
          <div
            className="fixed inset-0 bg-gray-600 bg-opacity-75"
            onClick={() => setSidebarOpen(false)}
          />
          <div className="relative flex-1 flex flex-col max-w-xs w-full bg-white">
            <div className="absolute top-0 right-0 -mr-12 pt-2">
              <button
                type="button"
                className="ml-1 flex items-center justify-center h-10 w-10 rounded-full focus:outline-none focus:ring-2 focus:ring-inset focus:ring-white"
                onClick={() => setSidebarOpen(false)}
              >
                <X className="h-6 w-6 text-white" />
              </button>
            </div>
            <SidebarContent
              navigation={navigation}
              user={user}
              handleLogout={handleLogout}
            />
          </div>
        </div>
      )}

      {/* Desktop sidebar */}
      <div className="hidden md:flex md:w-64 md:flex-col md:fixed md:inset-y-0">
        <SidebarContent
          navigation={navigation}
          user={user}
          handleLogout={handleLogout}
        />
      </div>

      {/* Main content */}
      <div className="flex flex-col w-0 flex-1 overflow-hidden md:ml-64">
        <div className="md:hidden pl-1 pt-1 sm:pl-3 sm:pt-3">
          <button
            type="button"
            className="-ml-0.5 -mt-0.5 h-12 w-12 inline-flex items-center justify-center rounded-md text-gray-500 hover:text-gray-900 focus:outline-none focus:ring-2 focus:ring-inset focus:ring-indigo-500"
            onClick={() => setSidebarOpen(true)}
          >
            <Menu className="h-6 w-6" />
          </button>
        </div>

        <main className="flex-1 relative overflow-y-auto focus:outline-none">
          <div className="py-6">
            <div className="max-w-7xl mx-auto px-4 sm:px-6 md:px-8">
              <h1 className="text-2xl font-semibold text-gray-900">
                Dashboard
              </h1>
              <p className="text-gray-600 mt-1">Welcome back, {user?.name}</p>
            </div>

            <div className="max-w-7xl mx-auto px-4 sm:px-6 md:px-8">
              {/* Stats */}
              <div className="mt-6 grid grid-cols-1 gap-5 sm:grid-cols-2 lg:grid-cols-4">
                {stats.map((item) => (
                  <Card
                    key={item.name}
                    className="hover:shadow-md transition-shadow duration-200"
                  >
                    <CardContent className="p-6">
                      <div className="flex items-center">
                        <div className="flex-shrink-0">
                          <item.icon className="h-8 w-8 text-blue-600" />
                        </div>
                        <div className="ml-5 w-0 flex-1">
                          <dl>
                            <dt className="text-sm font-medium text-gray-500 truncate">
                              {item.name}
                            </dt>
                            <dd className="flex items-baseline">
                              <div className="text-2xl font-semibold text-gray-900">
                                {item.value}
                              </div>
                              <div className="ml-2 flex items-baseline text-sm font-semibold text-green-600">
                                <TrendingUp className="self-center flex-shrink-0 h-3 w-3 text-green-500" />
                                <span className="sr-only">Increased by</span>
                                {item.change}
                              </div>
                            </dd>
                          </dl>
                        </div>
                      </div>
                    </CardContent>
                  </Card>
                ))}
              </div>

              {/* Main content area */}
              <div className="mt-8">
                <div className="grid grid-cols-1 gap-6 lg:grid-cols-2">
                  <Card>
                    <CardHeader>
                      <CardTitle>Recent Activity</CardTitle>
                    </CardHeader>
                    <CardContent>
                      <div className="space-y-4">
                        {[1, 2, 3, 4].map((i) => (
                          <div key={i} className="flex items-center space-x-3">
                            <div className="w-2 h-2 bg-blue-600 rounded-full"></div>
                            <div className="flex-1">
                              <p className="text-sm text-gray-900">
                                User activity #{i}
                              </p>
                              <p className="text-xs text-gray-500 flex items-center mt-1">
                                <Clock className="w-3 h-3 mr-1" />
                                {i} hour{i > 1 ? "s" : ""} ago
                              </p>
                            </div>
                          </div>
                        ))}
                      </div>
                    </CardContent>
                  </Card>

                  <Card>
                    <CardHeader>
                      <CardTitle>Quick Actions</CardTitle>
                    </CardHeader>
                    <CardContent>
                      <div className="grid grid-cols-1 gap-3">
                        <Button variant="outline" className="justify-start">
                          <Users className="w-4 h-4 mr-2" />
                          Manage Users
                        </Button>
                        <Button variant="outline" className="justify-start">
                          <BarChart3 className="w-4 h-4 mr-2" />
                          View Reports
                        </Button>
                        <Button variant="outline" className="justify-start">
                          <Settings className="w-4 h-4 mr-2" />
                          System Settings
                        </Button>
                        <Button
                          variant="outline"
                          className="justify-start"
                          onClick={callFunctionApp}
                          disabled={loading}
                        >
                          <Activity className="w-4 h-4 mr-2" />
                          {loading ? "Calling..." : "Call Function App"}
                        </Button>
                      </div>

                      {functionData && (
                        <div className="mt-4 p-3 bg-gray-50 rounded-md">
                          <p className="text-sm font-medium text-gray-700">
                            Function App Response:
                          </p>
                          <pre className="text-xs text-gray-600 mt-1 overflow-x-auto">
                            {JSON.stringify(functionData, null, 2)}
                          </pre>
                        </div>
                      )}
                    </CardContent>
                  </Card>
                </div>
              </div>

              {children}
            </div>
          </div>
        </main>
      </div>
    </div>
  );
}

function SidebarContent({ navigation, user, handleLogout }: any) {
  return (
    <div className="flex-1 flex flex-col min-h-0 bg-white border-r border-gray-200">
      <div className="flex-1 flex flex-col pt-5 pb-4 overflow-y-auto">
        <div className="flex items-center flex-shrink-0 px-4">
          <div className="flex items-center space-x-3">
            <div className="w-8 h-8 bg-blue-600 rounded-lg flex items-center justify-center">
              <BarChart3 className="w-5 h-5 text-white" />
            </div>
            <h1 className="text-xl font-bold text-gray-900">Dashboard</h1>
          </div>
        </div>

        <nav className="mt-8 flex-1 px-2 space-y-1">
          {navigation.map((item: any) => (
            <a
              key={item.name}
              href={item.href}
              className={cn(
                item.current
                  ? "bg-blue-50 border-blue-500 text-blue-700"
                  : "border-transparent text-gray-600 hover:bg-gray-50 hover:text-gray-900",
                "group flex items-center px-3 py-2 text-sm font-medium border-l-4 rounded-r-md transition-colors duration-150"
              )}
            >
              <item.icon
                className={cn(
                  item.current
                    ? "text-blue-500"
                    : "text-gray-400 group-hover:text-gray-500",
                  "mr-3 flex-shrink-0 h-5 w-5"
                )}
              />
              {item.name}
            </a>
          ))}
        </nav>
      </div>

      <div className="flex-shrink-0 flex border-t border-gray-200 p-4">
        <div className="flex items-center space-x-3 group w-full">
          <div>
            <Avatar className="h-10 w-10">
              <AvatarImage
                src={
                  user?.image ||
                  `https://ui-avatars.com/api/?name=${encodeURIComponent(
                    user?.name || "User"
                  )}&background=2563eb&color=fff`
                }
              />
              <AvatarFallback className="bg-blue-600 text-white">
                {user?.name
                  ?.split(" ")
                  .map((n: string) => n[0])
                  .join("")
                  .toUpperCase() || "U"}
              </AvatarFallback>
            </Avatar>
          </div>
          <div className="flex-1 min-w-0">
            <p className="text-sm font-medium text-gray-900 truncate">
              {user?.name}
            </p>
            <p className="text-xs text-gray-500 truncate">{user?.email}</p>
          </div>
          <Button
            variant="ghost"
            size="sm"
            onClick={handleLogout}
            className="opacity-0 group-hover:opacity-100 transition-opacity"
          >
            <LogOut className="h-4 w-4" />
          </Button>
        </div>
      </div>
    </div>
  );
}
